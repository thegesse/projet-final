package com.goose.notspot.service.playlistService.modifyPlaylistServices;

import com.goose.notspot.model.playlists.DTO.PlaylistVisuals;
import com.goose.notspot.model.playlists.Playlist;
import com.goose.notspot.model.requestDTO.playlist.RemoveSongRequest;
import com.goose.notspot.model.songs.DTO.SongDTO;
import com.goose.notspot.model.songs.Song;
import com.goose.notspot.repository.PlaylistRepository;
import com.goose.notspot.repository.SongRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RemoveSongInPlaylistService {
    private final PlaylistRepository playlistRepository;
    private final SongRepository songRepository;

    public RemoveSongInPlaylistService(PlaylistRepository playlistRepository, SongRepository songRepository) {
        this.playlistRepository = playlistRepository;
        this.songRepository = songRepository;
    }

    private PlaylistVisuals mapToDTO(Playlist playlist) {
        List<SongDTO> songs = playlist.getSongs()
                .stream()
                .map(song -> new SongDTO(
                        song.getId(),
                        song.getTitle(),
                        song.getArtist(),
                        "/songs/" + song.getId() + "/stream"
                ))
                .toList();
        return new PlaylistVisuals(playlist.getId(), playlist.getTitle(), songs);
    }

    public PlaylistVisuals removeSongFromPlaylist(Long playlistId, String username, RemoveSongRequest request) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("playlist not found"));

        if(!playlist.getOwner().getUsername().equals(username)) {
            throw new RuntimeException("you dont own this playlist");
        }

        Song song = songRepository.findById(request.songId())
                .orElseThrow(() -> new RuntimeException("song not found"));

        playlist.getSongs().remove(song);

        Playlist savedPlaylist = playlistRepository.save(playlist);
        return mapToDTO(savedPlaylist);
    }
}
