package com.goose.notspot.service.playlistService.playlistAndSongServices;

import com.goose.notspot.model.playlists.Playlist;
import com.goose.notspot.repository.PlaylistRepository;
import com.goose.notspot.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;


@Service
public class PlaylistDeleteService {
    private final PlaylistRepository playlistRepository;

    public PlaylistDeleteService(PlaylistRepository playlistRepository, UserRepository userRepository) {
        this.playlistRepository = playlistRepository;
    }

    @Transactional
    public void delete(Long id, String username){

        Playlist playlist = playlistRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Playlist not found"));
        if(!playlist.getOwner().getUsername().equals(username)){
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permission to delete this playlist");
        }

        if(playlist.getTitle().equals("Liked Songs")) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Liked songs cannot be deleted");
        }

        playlistRepository.deleteById(id);
    }
}
