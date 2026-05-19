import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/songs/state/song_controller.dart';

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
    return Container(
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                flex: 1,
                child: TextField(
                  controller: _searchController,
                  cursorColor: Colors.grey,
                  onChanged: (value) {
                    context.read<SongController>().searchSongs(value);
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(15),
                      width: 18,
                      // Fallback icon until you add asset images
                      child: const Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.tune, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
