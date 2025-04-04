import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, GoogleAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import firebase_core

/// ! We use riverpod to watch the login state change, and rebuild screen.
/// ! For more details see the riverpod example.
final currentUserStreamProvider =
    StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

final currentUserProvider = StateProvider<User?>((ref) {
  return ref.watch(currentUserStreamProvider).maybeWhen(
        data: (user) => user,
        orElse: () => null,
      );
});

class FirebaseAuthUiExample extends ConsumerWidget {
  const FirebaseAuthUiExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(currentUserStreamProvider).when(
          data: (user) =>
              user == null ? _buildLoginScreen() : _buildProfileScreen(),
          error: (e, _) => Text(e.toString()),
          loading: () => const LinearProgressIndicator(),
        );
  }

  Widget _buildLoginScreen() {
    /// This SignInScreen comes from firebase_ui_auth package.
    return SignInScreen(
      headerBuilder: (context, constraints, _) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.account_circle, size: 100), // Thay thế kAppIcon
      ),
      footerBuilder: (context, _) {
        return ElevatedButton.icon(
          icon: const Icon(CommunityMaterialIcons.incognito),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
          label: const Text('Log in anonymously'),
          onPressed: () async {
            await FirebaseAuth.instance.signInAnonymously();
          },
        );
      },
    );
  }

  Widget _buildProfileScreen() {
    return const ProfileScreen(
      children: [
        Text(
            '🚀We could add more content to the profile screen via the children param.')
      ],
    );
  }
}
