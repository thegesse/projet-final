package com.goose.notspot.service.playlistService.findPlaylist;

import com.goose.notspot.model.playlists.DTO.ShortPlaylistVisuals;
import com.goose.notspot.model.playlists.Playlist;
import com.goose.notspot.repository.PlaylistRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GetAllPlaylists {
    private final PlaylistRepository playlistRepository;

    public GetAllPlaylists(PlaylistRepository playlistRepository) {
        this.playlistRepository = playlistRepository;
    }

    private ShortPlaylistVisuals mapToDTO(Playlist playlist) {
        return new ShortPlaylistVisuals(
                playlist.getId(),
                playlist.getTitle()
        );
    }

    public List<ShortPlaylistVisuals> getAllPlaylists(String username){
        return playlistRepository.findByOwnerUsername(username)
                .stream()
                .map(this::mapToDTO)
                .toList();
    }
}
