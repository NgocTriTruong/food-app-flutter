package org.example.food_app_be.controller;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/files")
public class FileController {

    private static final String UPLOAD_DIR = "uploads";
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss");

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, String>> upload(@RequestParam("file") MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        // Đảm bảo thư mục tồn tại
        Path uploadPath = Paths.get(UPLOAD_DIR).toAbsolutePath().normalize();
        Files.createDirectories(uploadPath);

        // Tạo tên file an toàn, kèm timestamp để tránh trùng
        String originalName = StringUtils.cleanPath(file.getOriginalFilename() == null ? "file" : file.getOriginalFilename());
        String extension = "";
        int idx = originalName.lastIndexOf('.');
        if (idx != -1) {
            extension = originalName.substring(idx);
        }
        String timestamp = LocalDateTime.now().format(FORMATTER);
        String safeName = UUID.randomUUID() + "_" + timestamp + extension;

        Path target = uploadPath.resolve(safeName).normalize();
        file.transferTo(target);

        // Tạo URL tuyệt đối từ base URL hiện tại
        String baseUrl = ServletUriComponentsBuilder.fromCurrentContextPath().build().toUriString();
        String absoluteUrl = baseUrl + "/uploads/" + safeName;

        Map<String, String> body = new HashMap<>();
        body.put("url", absoluteUrl);
        body.put("filename", safeName);
        return ResponseEntity.ok(body);
    }

    @DeleteMapping
    public ResponseEntity<Void> delete(@RequestParam("url") String url) throws IOException {
        if (url == null || url.isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        String normalized = url.replace("\\", "/");
        int idx = normalized.lastIndexOf('/');
        if (idx == -1) {
            return ResponseEntity.badRequest().build();
        }
        String filename = normalized.substring(idx + 1);

        Path uploadPath = Paths.get(UPLOAD_DIR).toAbsolutePath().normalize();
        Path target = uploadPath.resolve(filename).normalize();

        if (Files.exists(target)) {
            Files.delete(target);
        }

        return ResponseEntity.noContent().build();
    }
}
