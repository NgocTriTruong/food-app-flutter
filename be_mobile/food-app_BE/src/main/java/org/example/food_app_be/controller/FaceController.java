package org.example.food_app_be.controller;

import org.example.food_app_be.model.User;
import org.example.food_app_be.service.UserService;
import org.example.food_app_be.util.ImageHashUtil;
import org.example.food_app_be.util.JwtUtil;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.nio.file.Files;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/face")
public class FaceController {

    private final UserService userService;
    private final JwtUtil jwtUtil;

    public FaceController(UserService userService, JwtUtil jwtUtil) {
        this.userService = userService;
        this.jwtUtil = jwtUtil;
    }

    // Register face for authenticated user. Header: Authorization: Bearer <token>
    @PostMapping("/register")
    public ResponseEntity<?> registerFace(@RequestHeader(value = "Authorization", required = false) String auth,
                                          @RequestParam("image") MultipartFile image) {
        try {
            if (auth == null || !auth.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Missing Authorization token");
            }
            String token = auth.substring(7);
            if (!jwtUtil.validateToken(token)) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
            String userId = jwtUtil.getUserIdFromToken(token);

            Optional<User> uOpt = userService.getUserById(userId);
            if (uOpt.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
            User user = uOpt.get();

            // compute hash
            String hash = ImageHashUtil.averageHash(image.getInputStream());

            // save file under uploads/faces/<userId>.jpg
            File dir = new File("uploads/faces");
            if (!dir.exists()) dir.mkdirs();
            File dest = new File(dir, userId + ".jpg");
            try (FileOutputStream fos = new FileOutputStream(dest); InputStream in = image.getInputStream()) {
                byte[] buf = new byte[8192];
                int r;
                while ((r = in.read(buf)) != -1) fos.write(buf,0,r);
            }

            user.setFaceHash(hash);
            user.setFaceImagePath(dest.getAbsolutePath());
            user.setFaceIdEnabled(true);
            userService.save(user);

            return ResponseEntity.ok("Face registered successfully");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error: " + e.getMessage());
        }
    }

    // Login by face. Accepts image file and returns token if matched
    @PostMapping("/login")
    public ResponseEntity<?> loginByFace(@RequestParam("image") MultipartFile image) {
        try {
            String hash = ImageHashUtil.averageHash(image.getInputStream());

            List<User> users = userService.getAllUsers();
            User best = null;
            int bestDist = Integer.MAX_VALUE;
            int candidates = 0;
            for (User u : users) {
                if (u.getFaceHash() == null) continue;
                candidates++;
                int d = ImageHashUtil.hammingDistance(hash, u.getFaceHash());
                System.out.println("[FaceLogin] compare user=" + u.getId() + " dist=" + d);
                if (d < bestDist) {
                    bestDist = d;
                    best = u;
                }
            }

            final int THRESHOLD = 14; // increased tolerance
            System.out.println("[FaceLogin] candidates=" + candidates + " bestDist=" + bestDist + " threshold=" + THRESHOLD);

            if (best != null && bestDist <= THRESHOLD) {
                String token = jwtUtil.generateToken(best.getId(), best.getEmail());
                return ResponseEntity.ok(java.util.Map.of("token", token, "user", best, "distance", bestDist));
            }

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(java.util.Map.of("message", "Face not recognized", "bestDistance", bestDist, "candidates", candidates));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error: " + e.getMessage());
        }
    }

    // Optional: remove face
    @PostMapping("/unregister")
    public ResponseEntity<?> unregisterFace(@RequestHeader(value = "Authorization", required = false) String auth) {
        try {
            if (auth == null || !auth.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Missing Authorization token");
            }
            String token = auth.substring(7);
            if (!jwtUtil.validateToken(token)) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
            String userId = jwtUtil.getUserIdFromToken(token);

            Optional<User> uOpt = userService.getUserById(userId);
            if (uOpt.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
            User user = uOpt.get();
            user.setFaceHash(null);
            user.setFaceImagePath(null);
            user.setFaceIdEnabled(false);
            userService.save(user);

            // delete file if exists
            try {
                Files.deleteIfExists(new File("uploads/faces/" + userId + ".jpg").toPath());
            } catch (Exception ignored) {}

            return ResponseEntity.ok("Face unregistered");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error: " + e.getMessage());
        }
    }

}
