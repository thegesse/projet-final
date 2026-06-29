import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/songs/state/song_controller.dart';
import '../../../features/playlist/state/playlist_controller.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FORCE DARK THEME CALCULATION ON TEXT INPUT CURSORS AND TEXT
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.purpleAccent,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  cursorColor: Colors.purpleAccent,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      context.read<PlaylistController>().clearCurrentPlaylist();
                    }
                    context.read<SongController>().searchSongs(value);
                  },
                  decoration: InputDecoration(
                    // Swapped out flat blinding white fill for a premium tinted transparent gray
                    fillColor: const Color(0xFF1E1E1E),
                    filled: true,
                    hintText: 'Search songs, artists...',
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 16,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                      child: Icon(Icons.search_rounded,
                          color: Colors.white60, size: 22),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Colors.purpleAccent, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Filter/Tune Control Button
              GestureDetector(
                onTap: () {
                  // Optional: handle opening search filter layouts later
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.purpleAccent.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.purpleAccent,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
