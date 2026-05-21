import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/songs/state/song_controller.dart';
import '../widgets/homescreen_header.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_list.dart';
//bc searchbar is already a thing
import '../widgets/searchbar.dart' as custom_search;


class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final songController = context.watch<SongController>();

    final songsToShow = songController.searchResults.isNotEmpty ? songController.searchResults : songController.songs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NotSpot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {context.read<AuthController>().logout();},
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomescreenHeader(),
              const custom_search.SearchBar(),
              const SizedBox(height: 16),

              if(songController.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()),)
              else if (songController.errorMessage != null)
                Expanded(
                  child: Center(
                    child: Text(songController.errorMessage!),
                  ),
                )
              else if (songsToShow.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('no songs available to display'),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: songsToShow.length,
                    itemBuilder: (context, index) {
                      final song = songsToShow[index];

                      return SongList(song: song, isCurrent: songController.currentSong?.id == song.id, onTap: () {songController.selectSong(song);},);
                    },
                  ),
                ),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }
}