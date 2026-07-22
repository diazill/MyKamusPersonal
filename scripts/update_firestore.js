const admin = require('firebase-admin');

// Ensure all environment variables are present
if (!process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
  console.error("Error: Missing FIREBASE_SERVICE_ACCOUNT_KEY environment variable.");
  process.exit(1);
}
if (!process.env.VERSION_TAG) {
  console.error("Error: Missing VERSION_TAG environment variable.");
  process.exit(1);
}

// Parse the service account key
let serviceAccount;
try {
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
} catch (error) {
  console.error("Error parsing FIREBASE_SERVICE_ACCOUNT_KEY:", error.message);
  process.exit(1);
}

// Parse the version string
// e.g. "v1.0.9" -> "1.0.9"
// e.g. "1.0.9+13" -> "1.0.9+13"
const version = process.env.VERSION_TAG.replace(/^v/i, '');
const versionWithoutBuild = version.includes('+') ? version.split('+')[0] : version;

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Build URLs exactly as expected
const apkUrl = `https://github.com/diazill/MyKamusPersonal/releases/download/v${versionWithoutBuild}/app-release.apk`;
const exeUrl = `https://github.com/diazill/MyKamusPersonal/releases/download/v${versionWithoutBuild}/MyKamusPersonal_Installer_v${versionWithoutBuild}.exe`;

async function updateFirestore() {
  try {
    const docRef = db.collection('app_config').doc('version_info');
    await docRef.update({
      latest_version: version,
      apk_url: apkUrl,
      exe_url: exeUrl,
      release_notes: `Pembaruan otomatis dari GitHub Actions untuk versi ${version}`
    });
    console.log(`Successfully updated Firestore version_info with latest_version: ${version}`);
    process.exit(0);
  } catch (error) {
    console.error('Error updating Firestore document:', error);
    process.exit(1);
  }
}

updateFirestore();
