import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../features/radio/controller/radio_controller.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final radioController = context.watch<RadioController>();
    final currentStation = radioController.currentStationName;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Radio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live lofi stations',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${radioController.stationNames.length} stations available',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    currentStation == null ? 24 : 132,
                  ),
                  sliver: SliverList.separated(
                    itemCount: radioController.stationNames.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final stationName = radioController.stationNames[index];
                      final isCurrent = currentStation == stationName;
                      final isPlaying = isCurrent && radioController.isPlaying;

                      return _StationTile(
                        stationName: stationName,
                        isCurrent: isCurrent,
                        isPlaying: isPlaying,
                        onTap: () => radioController.playStation(stationName),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (currentStation != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
                child: _RadioPlayerBar(radioController: radioController),
              ),
            ),
        ],
      ),
    );
  }
}

class _StationTile extends StatelessWidget {
  final String stationName;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;

  const _StationTile({
    required this.stationName,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrent ? Colors.purple.withOpacity(0.18) : Colors.white10,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrent
                  ? Colors.purpleAccent.withOpacity(0.55)
                  : Colors.white10,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.purple.withOpacity(0.3)
                      : Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPlaying ? Icons.graphic_eq_rounded : Icons.radio_rounded,
                  color: isCurrent ? Colors.purpleAccent : Colors.white54,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  stationName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: isCurrent ? Colors.purpleAccent : Colors.white70,
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioPlayerBar extends StatelessWidget {
  final RadioController radioController;

  const _RadioPlayerBar({required this.radioController});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.radio_rounded, color: Colors.purpleAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LIVE RADIO',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      radioController.currentStationName ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  radioController.isPlaying
                      ? Icons.stop_circle_rounded
                      : Icons.play_circle_fill_rounded,
                ),
                iconSize: 42,
                color: Colors.white,
                onPressed: () {
                  final stationName = radioController.currentStationName;
                  if (radioController.isPlaying) {
                    radioController.stopRadio();
                  } else if (stationName != null) {
                    radioController.playStation(stationName);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
