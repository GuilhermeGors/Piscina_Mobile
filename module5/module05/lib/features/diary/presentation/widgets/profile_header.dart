import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userProfilePhotoUrl;
  final VoidCallback onLogoutPressed;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userProfilePhotoUrl,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(userProfilePhotoUrl),
          backgroundColor: const Color.fromARGB(255, 173, 159, 199),
          child: CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 46,
              backgroundImage: NetworkImage(userProfilePhotoUrl),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Center(
            child: Text(
              userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: onLogoutPressed,
        ),
      ],
    );
  }
}
