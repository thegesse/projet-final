import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SideBarPc extends StatelessWidget {
  final Widget child;
  const SideBarPc({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    int selectedLocation = 0;

    if (location == '/home') selectedLocation = 0;
    if (location == '/playlists') selectedLocation = 1;
    if (location == '/radio') selectedLocation = 2;
    if (location == '/song') selectedLocation = 3;
    if (location == '/addSong') selectedLocation = 4;
    if (location == '/settings') selectedLocation = 5;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            backgroundColor: const Color(0xFF1E1E1E),
            selectedIconTheme:
                const IconThemeData(color: Colors.purple, size: 28),
            selectedLabelTextStyle: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedIconTheme: const IconThemeData(color: Colors.white60),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white60),
            selectedIndex: selectedLocation,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/playlists');
                  break;
                case 2:
                  context.go('/radio');
                  break;
                case 3:
                  context.go('/song');
                  break;
                case 4:
                  context.go('/addSong');
                  break;
                case 5:
                  context.go('/settings');
              }
            },
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.library_music, color: Colors.purple, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'NotSpot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.playlist_play_outlined),
                selectedIcon: Icon(Icons.playlist_play),
                label: Text('Playlists'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.radio_outlined),
                selectedIcon: Icon(Icons.radio),
                label: Text('Radio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.music_note_outlined),
                selectedIcon: Icon(Icons.music_note),
                label: Text('Playing'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_box_outlined),
                selectedIcon: Icon(Icons.add_box),
                label: Text('Add'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Colors.black26),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
