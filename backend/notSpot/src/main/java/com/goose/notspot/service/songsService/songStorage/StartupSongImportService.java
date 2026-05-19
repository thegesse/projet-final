package com.goose.notspot.service.songsService.songStorage;

import com.goose.notspot.model.songs.Song;
import com.goose.notspot.repository.SongRepository;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.UUID;
import java.util.stream.Stream;
//format of files artist - title.mp3
@Service
//application running so that it starts auto
public class StartupSongImportService implements ApplicationRunner {
    private static final Path UPLOAD_DIR = Paths.get("uploads/songs");

    private final SongRepository songRepository;

    public StartupSongImportService(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (!Files.isDirectory(UPLOAD_DIR)) {
            return;
        }

        try (Stream<Path> files = Files.list(UPLOAD_DIR)) {
            files.filter(Files::isRegularFile)
                    .filter(this::isAudioFile)
                    .filter(path -> !songRepository.existsByAudioPath(path.toString()))
                    .forEach(this::importSong);
        } catch (IOException e) {
            throw new RuntimeException("couldnt import startup songs", e);
        }
    }

    private boolean isAudioFile(Path path) {
        try {
            String contentType = Files.probeContentType(path);
            if (contentType != null && contentType.startsWith("audio/")) {
                return true;
            }
        } catch (IOException ignored) {
            // Fall back to the extension below.
        }

        String fileName = path.getFileName().toString().toLowerCase(Locale.ROOT);
        return fileName.endsWith(".mp3")
                || fileName.endsWith(".wav")
                || fileName.endsWith(".m4a")
                || fileName.endsWith(".aac")
                || fileName.endsWith(".ogg")
                || fileName.endsWith(".flac");
    }

    private void importSong(Path path) {
        SongMetadata metadata = metadataFromFileName(path.getFileName().toString());
        Path storedPath = moveToUuidFile(path);

        Song song = new Song();
        song.setTitle(metadata.title());
        song.setArtist(metadata.artist());
        song.setAudioPath(storedPath.toString());
        song.setContentType(contentType(storedPath));
        song.setFileSize(fileSize(storedPath));

        songRepository.save(song);
    }

    private Path moveToUuidFile(Path path) {
        String extension = getExtension(path.getFileName().toString());
        Path targetPath = uniqueTargetPath(extension);

        try {
            return Files.move(path, targetPath);
        } catch (IOException e) {
            throw new RuntimeException("couldnt rename imported song file", e);
        }
    }

    private Path uniqueTargetPath(String extension) {
        Path targetPath;
        do {
            targetPath = UPLOAD_DIR.resolve(UUID.randomUUID() + extension);
        } while (Files.exists(targetPath));

        return targetPath;
    }

    private SongMetadata metadataFromFileName(String fileName) {
        String name = stripExtension(fileName).trim();
        String[] parts = name.split("\\s+-\\s+", 2);

        if (parts.length == 2 && !parts[0].isBlank() && !parts[1].isBlank()) {
            return new SongMetadata(parts[1].trim(), parts[0].trim());
        }

        return new SongMetadata(name.isBlank() ? fileName : name, "Unknown Artist");
    }

    private String stripExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex <= 0) {
            return fileName;
        }
        return fileName.substring(0, dotIndex);
    }

    private String getExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex <= 0) {
            return "";
        }
        return fileName.substring(dotIndex);
    }

    private String contentType(Path path) {
        try {
            String contentType = Files.probeContentType(path);
            if (contentType != null) {
                return contentType;
            }
        } catch (IOException ignored) {
            // Use a generic audio content type if detection fails.
        }

        return "audio/mpeg";
    }

    private long fileSize(Path path) {
        try {
            return Files.size(path);
        } catch (IOException e) {
            throw new RuntimeException("couldnt read song file size", e);
        }
    }

    private record SongMetadata(String title, String artist) {
    }
}

//either way delete this file once it is deployed, it isnt needed after deployment since on startup only
