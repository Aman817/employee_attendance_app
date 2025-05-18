package com.example.employee_attendance_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class ReminderReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
                val message = intent?.getStringExtra("message")
                val id = intent?.getIntExtra("id", 0) ?: 0

                val notificationIntent =
                        Intent(context, MainActivity::class.java).apply {
                                flags =
                                        Intent.FLAG_ACTIVITY_NEW_TASK or
                                                Intent.FLAG_ACTIVITY_CLEAR_TASK
                        }

                val pendingIntent =
                        PendingIntent.getActivity(
                                context,
                                id,
                                notificationIntent,
                                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                        )

                val channelId = "reminder_channel"
                val notificationManager =
                        context?.getSystemService(Context.NOTIFICATION_SERVICE) as
                                NotificationManager

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val channel =
                                NotificationChannel(
                                        channelId,
                                        "Reminder Notifications",
                                        NotificationManager.IMPORTANCE_HIGH
                                )
                        notificationManager.createNotificationChannel(channel)
                }

                val notification: Notification =
                        NotificationCompat.Builder(context, channelId)
                                .setContentTitle("Reminder")
                                .setContentText(message ?: "It's time!")
                                .setSmallIcon(android.R.drawable.ic_dialog_info)
                                .setAutoCancel(true)
                                .setContentIntent(pendingIntent)
                                .build()

                notificationManager.notify(id, notification)
        }
}
