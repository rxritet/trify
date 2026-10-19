import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

Future<void> initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) return;

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
    } else {
      // Android obtains its options from android/app/google-services.json.
      await Firebase.initializeApp();
    }
  } on FirebaseException {
    // Local email/password access remains available until Android config is added.
  }
}
