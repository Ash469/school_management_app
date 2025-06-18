importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCU_A46qSy-gDHx6lHrkm8QWaixxFVDjjU",
  authDomain: "school-e04b8.firebaseapp.com",
  projectId: "school-e04b8",
  storageBucket: "school-e04b8.firebasestorage.app",
  messagingSenderId: "371745891018",
  appId: "1:371745891018:web:23a9a2c316c5ec0e88ca33",
  measurementId: "G-WR6VHEED9Q"
});

const messaging = firebase.messaging();

// Optional background message handler
messaging.onBackgroundMessage((payload) => {
  console.log("Background message received:", payload);
  
  // Customize notification here
  const notificationTitle = payload.notification.title || "New Notification";
  const notificationOptions = {
    body: payload.notification.body || "You have a new notification",
    icon: "/icons/icon-192x192.png"
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
