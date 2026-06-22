package com.goose.notspot.service.playlistService.playlistAndSongServices;

import com.goose.notspot.model.playlists.DTO.PlaylistVisuals;
import com.goose.notspot.model.playlists.Playlist;
import com.goose.notspot.model.requestDTO.playlist.AddSongRequest;
import com.goose.notspot.model.songs.DTO.SongDTO;
import com.goose.notspot.model.songs.Song;
import com.goose.notspot.repository.PlaylistRepository;
import com.goose.notspot.repository.SongRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class AddSongToPlaylistService {
    private final PlaylistRepository playlistRepository;
    private final SongRepository songRepository;

    public AddSongToPlaylistService(PlaylistRepository playlistRepository, SongRepository songRepository) {
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

    @Transactional
    public PlaylistVisuals addSong(Long playlistId, String username, AddSongRequest request) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "playlist not found"));

        if(!playlist.getOwner().getUsername().equals(username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "you dont own this playlist");
        }

        Long songId = request.songId();
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "song not found"));

        boolean alreadyInPlaylist = playlist.getSongs()
                .stream()
                .anyMatch(existing -> existing.getId() != null && existing.getId().equals(songId));

        if(!alreadyInPlaylist) {
            playlist.getSongs().add(song);
        }
        Playlist savedPlaylist = playlistRepository.save(playlist);
        return mapToDTO(savedPlaylist);
    }

}
