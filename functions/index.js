const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNewProductNotification = functions.firestore
    .document("products/{productId}")
    .onCreate((snap, context) => {
      const newValue = snap.data();

      const payload = {
        notification: {
          title: "New Product Added",
          body: `${newValue.name} is now available for $${newValue.price}`,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
        topic: "newProducts",
      };

      return admin.messaging().send(payload)
          .then((response) => {
            console.log("Successfully sent message:", response);
          })
          .catch((error) => {
            console.log("Error sending message:", error);
          });
    });
