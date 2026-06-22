package com.goose.notspot.service.playlistService.modifyPlaylistServices;

import com.goose.notspot.model.playlists.DTO.ShortPlaylistVisuals;
import com.goose.notspot.model.playlists.Playlist;
import com.goose.notspot.model.requestDTO.playlist.CreatePlaylistRequest;
import com.goose.notspot.model.user.User;
import com.goose.notspot.repository.PlaylistRepository;
import com.goose.notspot.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class PlaylistCreationService {
    private final PlaylistRepository playlistRepository;
    private final UserRepository userRepository;


    public PlaylistCreationService(PlaylistRepository playlistRepository, UserRepository userRepository) {
        this.playlistRepository = playlistRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public ShortPlaylistVisuals createPlaylist(Long userId, CreatePlaylistRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        Playlist playlist = new Playlist();
        playlist.setTitle(request.title());
        playlist.setOwner(user);

        Playlist savedPlaylist = playlistRepository.save(playlist);

        return new ShortPlaylistVisuals(savedPlaylist.getId(), savedPlaylist.getTitle());
    }
}
