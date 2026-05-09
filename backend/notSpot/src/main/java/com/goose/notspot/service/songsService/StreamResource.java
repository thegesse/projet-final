package com.goose.notspot.service.songsService;

import org.springframework.core.io.Resource;

public record StreamResource (
        Resource resource,
        String contentType,
        Long fileSize
){}
