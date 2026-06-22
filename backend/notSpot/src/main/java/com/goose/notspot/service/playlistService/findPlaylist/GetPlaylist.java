package com.goose.notspot.service.playlistService.findPlaylist;

import com.goose.notspot.model.playlists.DTO.PlaylistVisuals;
import com.goose.notspot.model.playlists.Playlist;
import com.goose.notspot.model.songs.DTO.SongDTO;
import com.goose.notspot.repository.PlaylistRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class GetPlaylist {
    private final PlaylistRepository playlistRepository;

    public GetPlaylist(PlaylistRepository playlistRepository) {
        this.playlistRepository = playlistRepository;
    }

    @Transactional(readOnly = true)
    public PlaylistVisuals getPlaylist(Long playlistId, String username) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Playlist not found"));

        if (!playlist.getOwner().getUsername().equals(username)) {
            throw new AccessDeniedException("You don't have permission to view this playlist");
        }

        List<SongDTO> songs = playlist.getSongs()
                .stream()
                .map(song -> new SongDTO(
                        song.getId(),
                        song.getTitle(),
                        song.getArtist(),
                        "/songs/" + song.getId() + "/stream"
                ))
                .toList();

        return new PlaylistVisuals(
                playlist.getId(),
                playlist.getTitle(),
                songs
        );
    }
}
