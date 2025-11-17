// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBrDUiNUTdKMKAOFAm4LZ5BrxmFN9DC0Zs",
  authDomain: "palpites-top.firebaseapp.com",
  projectId: "palpites-top",
  storageBucket: "palpites-top.firebasestorage.app",
  messagingSenderId: "1007629393973",
  appId: "1:1007629393973:web:9c67f86c0971d55e08117c",
  measurementId: "G-HLLJTZZXV7"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);