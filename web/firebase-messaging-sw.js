importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDpUsqgyYovVyl7y48KzKUIo5VIWRWlo_E',
  authDomain: 'edu-nova-bd.firebaseapp.com',
  projectId: 'edu-nova-bd',
  storageBucket: 'edu-nova-bd.firebasestorage.app',
  messagingSenderId: '347117961120',
  appId: '1:347117961120:web:c0574b4af775d36c65eec5',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title || 'EduNova';
  const options = {
    body: payload.notification?.body,
    icon: '/icons/Icon-192.png',
    data: payload.data,
  };
  self.registration.showNotification(title, options);
});
