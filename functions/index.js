const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

// Initialize the Firebase Admin SDK
initializeApp();

/**
 * Cloud Function to send a push notification when a new message is created.
 * This uses the v2 syntax for Cloud Functions.
 */
exports.sendChatNotification = onDocumentCreated("chats/{chatId}/messages/{messageId}", async (event) => {
  // Get the new message data from the event
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with the event");
    return;
  }
  const messageData = snapshot.data();
  const senderId = messageData.senderId;
  const messageText = messageData.text;
  const messageType = messageData.type; // 0=text, 1=image, 2=call

  // Get the chat ID from the event parameters
  const chatId = event.params.chatId;

  // Get the chat document to find the participants
  const chatDoc = await getFirestore().collection("chats").doc(chatId).get();
  if (!chatDoc.exists) {
    console.log(`Chat document ${chatId} not found.`);
    return;
  }
  const chatData = chatDoc.data();
  const participants = chatData.participants;

  // Determine the recipient ID
  const recipientId = participants.find((p) => p !== senderId);
  if (!recipientId) {
    console.log("Recipient not found.");
    return;
  }

  // Get the sender's and recipient's user profiles
  const senderDoc = await getFirestore().collection("users").doc(senderId).get();
  const recipientDoc = await getFirestore().collection("users").doc(recipientId).get();

  if (!senderDoc.exists || !recipientDoc.exists) {
    console.log("Sender or recipient document not found.");
    return;
  }

  const senderName = senderDoc.data().fullName;
  const recipientToken = recipientDoc.data().fcmToken;

  if (!recipientToken) {
    console.log(`Recipient ${recipientId} does not have an FCM token.`);
    return;
  }

  // Determine the notification body based on the message type
  let notificationBody;
  switch (messageType) {
    case 1: // Image
      notificationBody = "Sent you an image.";
      break;
    case 2: // Call
      notificationBody = messageText; // e.g., "Video call"
      break;
    default: // Text
      notificationBody = messageText;
      break;
  }

  // Construct the notification payload
  const payload = {
    notification: {
      title: senderName,
      body: notificationBody,
      sound: "default",
    },
    data: {
      // You can add custom data here to handle navigation
      "chatId": chatId,
      "senderId": senderId,
    },
  };

  // Send the notification
  try {
    const response = await getMessaging().sendToDevice(recipientToken, payload);
    console.log("Successfully sent message:", response);
  } catch (error) {
    console.log("Error sending message:", error);
  }
});
