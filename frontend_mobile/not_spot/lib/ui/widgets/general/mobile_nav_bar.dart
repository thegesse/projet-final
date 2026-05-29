import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileNavBar extends StatelessWidget {
  final Widget child;
  const MobileNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    //magic numbers, not reccomeneded I know but, only will be this number of pages during whole lifetime
    int selectedLocation = 0;

    if (location == '/home') selectedLocation = 0;
    if (location == '/playlists') selectedLocation = 1;
    if (location == '/song') selectedLocation = 2;
    if (location == '/addSong') selectedLocation = 3;
    if (location == '/settings') selectedLocation = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.white60,
        currentIndex: selectedLocation,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/playlists');
              break;
            case 2:
              context.go('/song');
              break;
            case 3:
              context.go('/addSong');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.playlist_play), label: 'Playlists'),
          BottomNavigationBarItem(
              icon: Icon(Icons.music_note), label: 'Playing'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
