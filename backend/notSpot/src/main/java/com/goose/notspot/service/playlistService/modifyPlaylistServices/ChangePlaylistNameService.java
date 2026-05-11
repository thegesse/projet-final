package com.goose.notspot.service.playlistService.modifyPlaylistServices;

import com.goose.notspot.model.playlists.DTO.ShortPlaylistVisuals;
import com.goose.notspot.model.playlists.Playlist;
import com.goose.notspot.model.requestDTO.playlist.RenamePlaylistRequest;
import com.goose.notspot.repository.PlaylistRepository;
import org.springframework.stereotype.Service;

@Service
public class ChangePlaylistNameService {
    private final PlaylistRepository playlistRepository;

    public ChangePlaylistNameService(PlaylistRepository playlistRepository) {
        this.playlistRepository = playlistRepository;
    }

    public ShortPlaylistVisuals changePlaylistName(Long playlistId, String username, RenamePlaylistRequest request) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("playlist not found"));

        if(!playlist.getOwner().getUsername().equals(username)) {
            throw new RuntimeException("playlist not owned");
        }

        if(playlist.getTitle().equals("Liked Songs")) {
            throw new IllegalStateException("Liked songs cannot be renamed");
        }
        playlist.setTitle(request.title());

        Playlist savedPlaylist = playlistRepository.save(playlist);

        return new ShortPlaylistVisuals(savedPlaylist.getId(),  savedPlaylist.getTitle());
    }
}
