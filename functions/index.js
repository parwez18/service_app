const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotificationOnCreate = onDocumentCreated("notifications/{notificationId}", async (event) => {
  const notification = event.data.data();
  
  const userDoc = await admin.firestore()
    .collection("users")
    .doc(notification.recipientId)
    .get();
    
  const fcmToken = userDoc.data()?.fcmToken;
  
  if (!fcmToken) {
    console.log("No FCM token for user:", notification.recipientId);
    return;
  }

  const message = {
    notification: {
      title: notification.title || "New Notification",
      body: notification.body || "",
    },
    data: {  // ⬅️ Add this data object
    bookingId: notification.bookingId || "",
    type: notification.type || "",
  },
    token: fcmToken,
  };

  await admin.messaging().send(message);
  console.log("Notification sent successfully!");
});

// NEW: Auto-start bookings every 5 minutes
exports.autoStartBookings = onSchedule(
  {
    schedule: "*/5 * * * *", // Every 5 minutes (cron format)
    timeZone: "Asia/Kolkata", // Set your timezone
  },
  async (event) => {
    const now = admin.firestore.Timestamp.now();
    const nowDate = now.toDate();
    console.log("🔄 Checking for bookings to auto-start...");

    try {
      const acceptedBookings = await admin
        .firestore()
        .collection("bookings")
        .where("status", "==", "accepted")
        .get();

      if (acceptedBookings.empty) {
        console.log("No accepted bookings found");
        return null;
      }

      const batch = admin.firestore().batch();
      let updated = 0;

      acceptedBookings.docs.forEach((doc) => {
        const booking = doc.data();
        const bookingDate = booking.bookingDate.toDate();

        // Parse booking start time (format: "10:00 AM" or "10:00")
        const startTime = booking.bookingStartTime;
        const timeMatch = startTime.match(/(\d+):(\d+)\s*(AM|PM)?/i);

        if (!timeMatch) {
          console.log(
            `⚠️ Invalid time format for booking ${doc.id}: ${startTime}`
          );
          return;
        }

        let hours = parseInt(timeMatch[1]);
        const minutes = parseInt(timeMatch[2]);
        const period = timeMatch[3] ? timeMatch[3].toUpperCase() : null;

        // Convert to 24-hour format if AM/PM is present
        if (period) {
          if (period === "PM" && hours !== 12) {
            hours += 12;
          } else if (period === "AM" && hours === 12) {
            hours = 0;
          }
        }

        // Create booking start datetime
        const bookingStartTime = new Date(
          bookingDate.getFullYear(),
          bookingDate.getMonth(),
          bookingDate.getDate(),
          hours,
          minutes,
          0,
          0
        );

        // If current time >= start time, mark as ongoing
        if (nowDate >= bookingStartTime) {
          batch.update(doc.ref, {
            status: "ongoing",
            updatedAt: now,
            autoStartedAt: now,
          });
          updated++;
          console.log(
            `✅ Auto-starting booking ${doc.id} (scheduled: ${bookingStartTime.toISOString()})`
          );
        }
      });

      if (updated > 0) {
        await batch.commit();
        console.log(`🎉 Successfully auto-started ${updated} booking(s)`);
      } else {
        console.log("✓ No bookings need to be started at this time");
      }

      return null;
    } catch (error) {
      console.error("❌ Error in autoStartBookings:", error);
      return null;
    }
  }
);