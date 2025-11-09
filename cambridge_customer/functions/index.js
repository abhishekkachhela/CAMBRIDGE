import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK
admin.initializeApp();

// Example function triggered when a new order is placed
export const sendOrderNotification = functions.firestore
  .document('orders/{orderId}')
  .onCreate((snapshot, context) => {
    const orderData = snapshot.data();
    const userId = orderData.userId;

    // Get FCM token from Firestore or Realtime Database where you stored it
    return admin.firestore().collection('users').doc(userId).get()
      .then(userSnapshot => {
        const userData = userSnapshot.data();
        const fcmToken = userData.fcmToken;

        // Notification payload
        const payload = {
          notification: {
            title: "New Order",
            body: `Order #${context.params.orderId} has been placed!`,
          }
        };

        // Send notification to the user's device
        return admin.messaging().sendToDevice(fcmToken, payload);
      })
      .catch(error => {
        console.error("Error sending notification:", error);
      });
  });
