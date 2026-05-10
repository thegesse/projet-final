package com.goose.notspot.service.playlistService;

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

    public List<Playlist> getAllPlaylists(String username){

    }
}
