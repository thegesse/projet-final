package com.goose.notspot.service.songsService.songStorage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

import java.io.IOException;
import java.util.UUID;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;

@Service
public class StoreSongService {
    private final Path uploadDir;

    public StoreSongService(@Value("${app.song-storage.dir}") String uploadDir) {
        this.uploadDir = Paths.get(uploadDir);
    }


    private String getExtension(String fileName) {
        if(fileName == null || !fileName.contains(".")) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf("."));
    }

    public String save(MultipartFile file) {
        if(file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "file empty");
        }
        String contentType = file.getContentType();
        if(contentType == null || !contentType.contains("audio/")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "invalid content type");
        }
        String extension = getExtension(file.getOriginalFilename());
        String storedName = UUID.randomUUID().toString() + extension;
        try {
            Files.createDirectories(uploadDir);
            Path targetPath = uploadDir.resolve(storedName);
            Files.copy(file.getInputStream(), targetPath);

            return targetPath.toString();
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "couldnt save file", e);
        }
    }

    public Resource load(String audioPath) {
        try {
            Path path = Paths.get(audioPath);
            Resource resource = new UrlResource(path.toUri());

            if (!resource.exists() || !resource.isReadable()) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "audio file not found");
            }

            return resource;
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "couldnt load file", e);
        }
    }

    public void delete(String audioPath) {
        try {
            Files.deleteIfExists(Paths.get(audioPath));
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "couldnt delete file", e);
        }
    }
}
