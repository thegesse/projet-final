package com.goose.notspot.model.songs;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@NoArgsConstructor
@Data
public class songs {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String artist;
    private String audioPath;
    //to send correct file extensions
    private String contentType;
    //for later; size management
    private Long fileSize;
}
