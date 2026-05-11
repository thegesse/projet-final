package com.goose.notspot.controller;

import com.goose.notspot.model.playlists.DTO.PlaylistVisuals;
import com.goose.notspot.model.playlists.DTO.ShortPlaylistVisuals;
import com.goose.notspot.model.requestDTO.playlist.AddSongRequest;
import com.goose.notspot.model.requestDTO.playlist.CreatePlaylistRequest;
import com.goose.notspot.model.requestDTO.playlist.RemoveSongRequest;
import com.goose.notspot.model.requestDTO.playlist.RenamePlaylistRequest;
import com.goose.notspot.service.playlistService.findPlaylist.GetAllPlaylists;
import com.goose.notspot.service.playlistService.findPlaylist.GetPlaylist;
import com.goose.notspot.service.playlistService.modifyPlaylistServices.ChangePlaylistNameService;
import com.goose.notspot.service.playlistService.modifyPlaylistServices.PlaylistCreationService;
import com.goose.notspot.service.playlistService.modifyPlaylistServices.RemoveSongInPlaylistService;
import com.goose.notspot.service.playlistService.playlistAndSongServices.AddSongToPlaylistService;
import com.goose.notspot.service.playlistService.playlistAndSongServices.PlaylistDeleteService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/playlists")
public class PlaylistController {
    private final GetAllPlaylists getAllPlaylists;
    private final GetPlaylist getPlaylist;
    private final ChangePlaylistNameService changePlaylistNameService;
    private final PlaylistCreationService  playlistCreationService;
    private final RemoveSongInPlaylistService removeSongInPlaylistService;
    private final AddSongToPlaylistService addSongToPlaylistService;
    private final PlaylistDeleteService  playlistDeleteService;

    public PlaylistController(GetAllPlaylists getAllPlaylists, GetPlaylist getPlaylist, ChangePlaylistNameService changePlaylistNameService, PlaylistCreationService playlistCreationService, RemoveSongInPlaylistService removeSongInPlaylistService, AddSongToPlaylistService addSongToPlaylistService, PlaylistDeleteService playlistDeleteService) {
        this.getAllPlaylists = getAllPlaylists;
        this.getPlaylist = getPlaylist;
        this.changePlaylistNameService = changePlaylistNameService;
        this.playlistCreationService = playlistCreationService;
        this.removeSongInPlaylistService = removeSongInPlaylistService;
        this.addSongToPlaylistService = addSongToPlaylistService;
        this.playlistDeleteService = playlistDeleteService;
    }

    @PostMapping
    public ShortPlaylistVisuals createPlaylist(@RequestParam Long userId, @Valid @RequestBody CreatePlaylistRequest request) {
        return playlistCreationService.createPlaylist(userId, request);
    }

    @GetMapping
    public List<ShortPlaylistVisuals> getAllPlaylists(@RequestParam String username) {
        return getAllPlaylists.getAllPlaylists(username);
    }

    @GetMapping("/{playlistId}")
    public PlaylistVisuals getPlaylist(@PathVariable Long playlistId, @RequestParam String username) {
        return getPlaylist.getPlaylist(playlistId, username);
    }

    @PatchMapping("/{playlistId}")
    public ShortPlaylistVisuals renamePlaylist(@PathVariable Long playlistId, @RequestParam String username, @Valid @RequestBody RenamePlaylistRequest request) {
        return changePlaylistNameService.changePlaylistName(playlistId, username, request);
    }

    @DeleteMapping("/{playlistId}")
    public ResponseEntity<Void> deletePlaylist(@PathVariable Long playlistId, @RequestParam String username) {
        playlistDeleteService.delete(playlistId, username);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{playlistId}/song")
    public PlaylistVisuals addSong(@PathVariable Long playlistId, @RequestParam String username, @Valid @RequestBody AddSongRequest request) {
        return addSongToPlaylistService.addSong(playlistId, username, request);
    }

    @DeleteMapping("/{playlistId}/song")
    public PlaylistVisuals removeSong(@PathVariable Long playlistId, @RequestParam String username, @Valid @RequestBody RemoveSongRequest request) {
        return removeSongInPlaylistService.removeSongFromPlaylist(playlistId, username, request);
    }
}
