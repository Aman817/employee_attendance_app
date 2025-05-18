import UIKit
import Flutter
import AVFoundation
import CoreLocation
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let CAMERA_CHANNEL = "com.example.employee_attendance_app/camera"
    private let LOCATION_CHANNEL = "com.example.employee_attendance_app/location"
    private let REMINDER_CHANNEL = "com.example.employee_attendance_app/reminder"

    var locationManager: CLLocationManager?
    var resultCallback: FlutterResult?
    var imagePicker: UIImagePickerController?
    var currentViewController: UIViewController?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        currentViewController = controller


        let cameraChannel = FlutterMethodChannel(name: CAMERA_CHANNEL, binaryMessenger: controller.binaryMessenger)
        cameraChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "captureSelfie":
                self.resultCallback = result
                self.checkCameraPermissionAndPresent()
            default:
                result(FlutterMethodNotImplemented)
            }
        }

      
        let locationChannel = FlutterMethodChannel(name: LOCATION_CHANNEL, binaryMessenger: controller.binaryMessenger)
        locationChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "getCurrentLocation":
                self.resultCallback = result
                self.checkLocationPermissionAndFetch()
            default:
                result(FlutterMethodNotImplemented)
            }
        }


        let reminderChannel = FlutterMethodChannel(name: REMINDER_CHANNEL, binaryMessenger: controller.binaryMessenger)
        reminderChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "scheduleReminder":
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                    return
                }
                let checkInEnabled = args["checkInEnabled"] as? Bool ?? false
                let checkInTime = args["checkInTime"] as? String ?? ""
                let checkOutEnabled = args["checkOutEnabled"] as? Bool ?? false
                let checkOutTime = args["checkOutTime"] as? String ?? ""
                let message = args["message"] as? String ?? ""

                if checkInEnabled {
                    self.scheduleNotification(at: checkInTime, id: 0, message: message)
                }
                if checkOutEnabled {
                    self.scheduleNotification(at: checkOutTime, id: 1, message: message)
                }

                result("Reminders scheduled successfully")

            case "requestExactAlarmPermission":
              
                result("Not required for iOS")
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }


    private func checkCameraPermissionAndPresent() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            presentCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.presentCamera()
                    } else {
                        self.resultCallback?(FlutterError(code: "PERMISSION_DENIED", message: "Camera permission denied", details: nil))
                        self.resultCallback = nil
                    }
                }
            }
        default:
            self.resultCallback?(FlutterError(code: "PERMISSION_DENIED", message: "Camera permission denied", details: nil))
            self.resultCallback = nil
        }
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            resultCallback?(FlutterError(code: "NO_CAMERA", message: "Camera not available", details: nil))
            resultCallback = nil
            return
        }
        DispatchQueue.main.async {
            self.imagePicker = UIImagePickerController()
            self.imagePicker?.sourceType = .camera
            self.imagePicker?.delegate = self
            self.imagePicker?.cameraDevice = .front
            self.currentViewController?.present(self.imagePicker!, animated: true, completion: nil)
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let image = info[.originalImage] as? UIImage else {
            resultCallback?(FlutterError(code: "CAPTURE_FAILED", message: "Image capture failed", details: nil))
            resultCallback = nil
            return
        }

   
        if let data = image.jpegData(compressionQuality: 0.8) {
            let tempDir = NSTemporaryDirectory()
            let fileName = "selfie_\(UUID().uuidString).jpg"
            let fileURL = URL(fileURLWithPath: tempDir).appendingPathComponent(fileName)

            do {
                try data.write(to: fileURL)
                resultCallback?(fileURL.path)
            } catch {
                resultCallback?(FlutterError(code: "FILE_SAVE_FAILED", message: "Failed to save image", details: nil))
            }
        }
        resultCallback = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        resultCallback?(FlutterError(code: "CANCELLED", message: "User cancelled camera", details: nil))
        resultCallback = nil
    }

   
    private func checkLocationPermissionAndFetch() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }

        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            fetchLocation()
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        default:
            resultCallback?(FlutterError(code: "PERMISSION_DENIED", message: "Location permission denied", details: nil))
            resultCallback = nil
        }
    }

    private func fetchLocation() {
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            resultCallback?(FlutterError(code: "LOCATION_ERROR", message: "Unable to get location", details: nil))
            resultCallback = nil
            return
        }
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let placemark = placemarks?.first {
                let address = [
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")

                let locationMap: [String: Any] = [
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude,
                    "address": address
                ]
                self.resultCallback?(locationMap)
            } else {
                self.resultCallback?(FlutterError(code: "GEOCODER_FAILED", message: "Failed to get address", details: error?.localizedDescription))
            }
            self.resultCallback = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resultCallback?(FlutterError(code: "LOCATION_ERROR", message: "Failed to get location", details: error.localizedDescription))
        resultCallback = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            fetchLocation()
        } else if CLLocationManager.authorizationStatus() == .denied {
            resultCallback?(FlutterError(code: "PERMISSION_DENIED", message: "Location permission denied", details: nil))
            resultCallback = nil
        }
    }



    private func scheduleNotification(at time: String, id: Int, message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let date = formatter.date(from: time) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Attendance Reminder"
        content.body = message
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "attendance_reminder_\(id)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error.localizedDescription)")
            }
        }
    }
}
