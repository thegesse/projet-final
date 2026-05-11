package com.goose.notspot.controller;

import com.goose.notspot.model.requestDTO.ChangePasswordRequest;
import com.goose.notspot.model.requestDTO.ChangeUsernameRequest;
import com.goose.notspot.model.requestDTO.DeleteAccountRequest;
import com.goose.notspot.model.user.DTO.UserDTO;
import com.goose.notspot.service.userService.settings.ChangeNameService;
import com.goose.notspot.service.userService.settings.ChangePasswordService;
import com.goose.notspot.service.userService.settings.DeleteAccService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/settings")
public class UserSettingsController {
    private final ChangeNameService changeNameService;
    private final ChangePasswordService changePasswordService;
    private final DeleteAccService deleteAccService;

    public UserSettingsController(ChangeNameService changeNameService, ChangePasswordService changePasswordService, DeleteAccService deleteAccService) {
        this.changeNameService = changeNameService;
        this.changePasswordService = changePasswordService;
        this.deleteAccService = deleteAccService;
    }

    //patch is http request for only partial changes to a entity
    @PatchMapping("/users/{userId}/username")
    public ResponseEntity<UserDTO> changeUsername(@PathVariable Long userId, @Valid @RequestBody ChangeUsernameRequest request) {
        UserDTO updateUser = changeNameService.changeUsername(userId, request.username());
        return ResponseEntity.ok(updateUser);
    }

    @PatchMapping("/users/{userId}/password")
    public ResponseEntity<UserDTO> changePassword(@PathVariable Long userId, @Valid @RequestBody ChangePasswordRequest request) {

        changePasswordService.changePassword(userId, request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/users/{userId}")
    public ResponseEntity<UserDTO> deleteAcc(@PathVariable Long userId, @Valid @RequestBody DeleteAccountRequest request) {
        deleteAccService.deleteAccount(userId, request);
        return ResponseEntity.noContent().build();
    }
}
