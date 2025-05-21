import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }
}
