package com.goose.notspot.service.songsService.songStorage;

import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

class StoreSongServiceTest {

    private final StoreSongService storeSongService = new StoreSongService();

    @Test
    void rejectsNonAudioContentType() {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "song.mp3",
                "text/plain",
                "not audio".getBytes()
        );

        assertThatThrownBy(() -> storeSongService.save(file))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("invalid content type");
    }

    @Test
    void rejectsInvalidExtensionEvenWithAudioContentType() {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "song.exe",
                "audio/mpeg",
                "fake audio".getBytes()
        );

        assertThatThrownBy(() -> storeSongService.save(file))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("invalid audio extension");
    }
}
