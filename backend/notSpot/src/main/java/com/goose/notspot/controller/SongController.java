package com.goose.notspot.controller;

import com.goose.notspot.model.requestDTO.song.CreateSongRequest;
import com.goose.notspot.model.songs.DTO.SongDTO;
import com.goose.notspot.service.songsService.songSearch.GetAllSongs;
import com.goose.notspot.service.songsService.songSearch.GetRandomSong;
import com.goose.notspot.service.songsService.songSearch.GetSong;
import com.goose.notspot.service.songsService.songSearch.SearchSongService;
import com.goose.notspot.service.songsService.songStorage.AddSongService;
import com.goose.notspot.service.songsService.songStorage.DeleteSong;
import com.goose.notspot.service.songsService.songStream.StreamResource;
import com.goose.notspot.service.songsService.songStream.StreamSongService;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

//TODO use spring security later and use real auth instead of userid in user settings
@RestController
@RequestMapping("/songs")
public class SongController {
    private final AddSongService addSongService;
    private final GetAllSongs getAllSongs;
    private final GetSong getSong;
    private final SearchSongService searchSongService;
    private final GetRandomSong getRandomSong;
    private final StreamSongService streamSongService;
    private final DeleteSong deleteSong;

    public SongController(AddSongService addSongService, GetAllSongs getAllSongs, GetSong getSong, SearchSongService searchSongService, GetRandomSong getRandomSong, StreamSongService streamSongService, DeleteSong deleteSong) {
        this.addSongService = addSongService;
        this.getAllSongs = getAllSongs;
        this.getSong = getSong;
        this.searchSongService = searchSongService;
        this.getRandomSong = getRandomSong;
        this.streamSongService = streamSongService;
        this.deleteSong = deleteSong;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public SongDTO addSong(@RequestParam String title, @RequestParam String artist, @RequestPart MultipartFile file) {
        CreateSongRequest request = new CreateSongRequest(title, artist);
        return addSongService.addSong(request, file);
    }

    @GetMapping
    public List<SongDTO> getSongs() {
        return getAllSongs.findAll();
    }

    @GetMapping("/{songId}")
    public SongDTO getSong(@PathVariable Long songId) {
        return getSong.findSong(songId);
    }

    @GetMapping("/search")
    public List<SongDTO> searchSongs(@RequestParam String query){
        return searchSongService.search(query);
    }

    @GetMapping("/random")
    public SongDTO getRandomSong() {
        return getRandomSong.getRandomSong();
    }

    @GetMapping("/{songId}/stream")
    public ResponseEntity<Resource> streamSong(@PathVariable Long songId) {
        StreamResource stream = streamSongService.streamSong(songId);

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(stream.contentType()))
                .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(stream.fileSize()))
                .body(stream.resource());
    }

    @DeleteMapping("/{songId}")
    public ResponseEntity<Void> deleteSong(@PathVariable Long songId) {
        deleteSong.deleteSong(songId);
        return ResponseEntity.noContent().build();
    }


}
