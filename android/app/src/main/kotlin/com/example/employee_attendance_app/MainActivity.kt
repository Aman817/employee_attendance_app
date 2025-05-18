package com.example.employee_attendance_app

import android.Manifest
import android.app.Activity
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Geocoder
import android.location.Location
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : FlutterActivity() {

    private val CAMERA_CHANNEL = "com.example.employee_attendance_app/camera"
    private val LOCATION_CHANNEL = "com.example.employee_attendance_app/location"
    private val REMINDER_CHANNEL = "com.example.employee_attendance_app/reminder"

    private val REQUEST_IMAGE_CAPTURE = 1
    private val REQUEST_CAMERA_PERMISSION = 1001
    private val REQUEST_LOCATION_PERMISSION = 1002

    private var currentPhotoPath: String? = null
    private var pendingResult: MethodChannel.Result? = null
    private var fusedLocationClient: FusedLocationProviderClient? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAMERA_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "captureSelfie" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                        pendingResult = result
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), REQUEST_CAMERA_PERMISSION)
                    } else {
                        pendingResult = result
                        dispatchTakePictureIntent()
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCurrentLocation" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                        pendingResult = result
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), REQUEST_LOCATION_PERMISSION)
                    } else {
                        getCurrentLocation(result)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, REMINDER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleReminder" -> {
                    val checkInEnabled = call.argument<Boolean>("checkInEnabled") ?: false
                    val checkInTime = call.argument<String>("checkInTime") ?: ""
                    val checkOutEnabled = call.argument<Boolean>("checkOutEnabled") ?: false
                    val checkOutTime = call.argument<String>("checkOutTime") ?: ""
                    val message = call.argument<String>("message") ?: ""
        
                    if (checkInEnabled) scheduleReminder(checkInTime, message, 0)
                    if (checkOutEnabled) scheduleReminder(checkOutTime, message, 1)
        
                    result.success("Reminders scheduled successfully")
                }
        
                "requestExactAlarmPermission" -> {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        if (!alarmManager.canScheduleExactAlarms()) {
                            val intent = Intent(android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                            startActivity(intent)
                            result.success("Permission requested")
                        } else {
                            result.success("Permission already granted")
                        }
                    } else {
                        result.success("Not required for this Android version")
                    }
                }
        
                else -> result.notImplemented()
            }
        }
    }

    private fun dispatchTakePictureIntent() {
        val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        if (takePictureIntent.resolveActivity(packageManager) != null) {
            val photoFile = try {
                createImageFile()
            } catch (ex: IOException) {
                null
            }

            photoFile?.also {
                val photoURI = FileProvider.getUriForFile(this, "com.example.employee_attendance_app.fileprovider", it)
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
                startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE)
            } ?: run {
                pendingResult?.error("FILE_CREATION_FAILED", "Could not create file for photo.", null)
                pendingResult = null
            }
        }
    }

    private fun createImageFile(): File {
        val storageDir: File = getExternalFilesDir(Environment.DIRECTORY_PICTURES)!!
        return File.createTempFile("JPEG_${System.currentTimeMillis()}_", ".jpg", storageDir).apply {
            currentPhotoPath = absolutePath
        }
    }

    private fun getCurrentLocation(result: MethodChannel.Result) {
        fusedLocationClient?.lastLocation
            ?.addOnSuccessListener { location: Location? ->
                if (location != null) {
                    val geocoder = Geocoder(this, Locale.getDefault())
                    var addressText = "Unknown location"
                    try {
                        val addresses = geocoder.getFromLocation(location.latitude, location.longitude, 1)
                        if (!addresses.isNullOrEmpty()) {
                            val address = addresses[0]
                            addressText = listOfNotNull(
                                address.thoroughfare,
                                address.locality,
                                address.adminArea,
                                address.countryName
                            ).joinToString(", ")
                        }
                    } catch (e: Exception) {
                        addressText = "Geocoder failed"
                    }

                    val locationMap = mapOf(
                        "latitude" to location.latitude,
                        "longitude" to location.longitude,
                        "address" to addressText
                    )
                    result.success(locationMap)
                } else {
                    result.error("LOCATION_ERROR", "Unable to get location.", null)
                }
            }
            ?.addOnFailureListener {
                result.error("LOCATION_ERROR", "Failed to get location.", it.localizedMessage)
            }
    }

    private fun scheduleReminder(time: String, message: String, id: Int) {
        val format = SimpleDateFormat("HH:mm", Locale.getDefault())
        val inputDate = format.parse(time)
        val now = Calendar.getInstance()
        val reminderTime = Calendar.getInstance()

        if (inputDate != null) {
            reminderTime.set(Calendar.HOUR_OF_DAY, inputDate.hours)
            reminderTime.set(Calendar.MINUTE, inputDate.minutes)
            reminderTime.set(Calendar.SECOND, 0)

            if (reminderTime.before(now)) {
                reminderTime.add(Calendar.DAY_OF_YEAR, 1)
            }

            val intent = Intent(this, ReminderReceiver::class.java).apply {
                putExtra("message", message)
                putExtra("id", id)
            }

            val pendingIntent = PendingIntent.getBroadcast(this, id, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, reminderTime.timeInMillis, pendingIntent)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            REQUEST_CAMERA_PERMISSION -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    dispatchTakePictureIntent()
                } else {
                    pendingResult?.error("PERMISSION_DENIED", "Camera permission denied", null)
                    pendingResult = null
                }
            }
            REQUEST_LOCATION_PERMISSION -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    pendingResult?.let { getCurrentLocation(it) }
                } else {
                    pendingResult?.error("PERMISSION_DENIED", "Location permission denied", null)
                    pendingResult = null
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == Activity.RESULT_OK) {
            val file = File(currentPhotoPath!!)
            if (file.exists() && file.length() > 0) {
                Log.d("MainActivity", "Image captured at: $currentPhotoPath")
                pendingResult?.success(currentPhotoPath)
            } else {
                pendingResult?.error("EMPTY_FILE", "Captured image is empty.", null)
            }
        } else if (resultCode == Activity.RESULT_CANCELED) {
            pendingResult?.error("CANCELLED", "User cancelled camera.", null)
        } else {
            pendingResult?.error("CAPTURE_FAILED", "Camera capture failed.", null)
        }
        pendingResult = null
    }
}
