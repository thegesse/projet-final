package com.goose.notspot.security;

import com.goose.notspot.model.user.User;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class JwtService {
    private static final String HMAC_ALGORITHM = "HmacSHA256";
    private static final long EXPIRATION_SECONDS = 60 * 60 * 24;
    private static final String SECRET = System.getenv().getOrDefault(
            "NOTSPOT_JWT_SECRET",
            "change-this-dev-secret-before-deployment-change-this-dev-secret"
    );

    public String generateToken(User user) {
        Instant now = Instant.now();
        Map<String, Object> claims = new LinkedHashMap<>();
        claims.put("sub", user.getUsername());
        claims.put("role", effectiveRole(user));
        claims.put("iat", now.getEpochSecond());
        claims.put("exp", now.plusSeconds(EXPIRATION_SECONDS).getEpochSecond());

        String header = base64Url("{\"alg\":\"HS256\",\"typ\":\"JWT\"}".getBytes(StandardCharsets.UTF_8));
        String payload = base64Url(toJson(claims).getBytes(StandardCharsets.UTF_8));
        String signature = sign(header + "." + payload);
        return header + "." + payload + "." + signature;
    }

    public String extractUsername(String token) {
        try {
            return stringClaim(token, "sub");
        } catch (RuntimeException exception) {
            return null;
        }
    }

    public boolean isValid(String token, String username) {
        if (token == null || username == null) {
            return false;
        }
        try {
            String[] parts = token.split("\\.");
            if (parts.length != 3) {
                return false;
            }
            String expectedSignature = sign(parts[0] + "." + parts[1]);
            if (!constantTimeEquals(expectedSignature, parts[2])) {
                return false;
            }
            if (!username.equals(extractUsername(token))) {
                return false;
            }
            Long expiration = longClaim(token, "exp");
            return expiration != null && expiration > Instant.now().getEpochSecond();
        } catch (RuntimeException exception) {
            return false;
        }
    }

    private String effectiveRole(User user) {
        return user.getRole() == null ? "USER" : user.getRole().name();
    }

    private String sign(String value) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            mac.init(new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), HMAC_ALGORITHM));
            return base64Url(mac.doFinal(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception exception) {
            throw new IllegalStateException("Could not sign token", exception);
        }
    }

    private String stringClaim(String token, String claim) {
        Object value = claims(token).get(claim);
        return value instanceof String string ? string : null;
    }

    private Long longClaim(String token, String claim) {
        Object value = claims(token).get(claim);
        return value instanceof Number number ? number.longValue() : null;
    }

    private Map<String, Object> claims(String token) {
        String[] parts = token.split("\\.");
        if (parts.length != 3) {
            return Map.of();
        }
        String json = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);
        return parseFlatJson(json);
    }

    private Map<String, Object> parseFlatJson(String json) {
        Map<String, Object> values = new LinkedHashMap<>();
        String content = json.trim();
        if (content.startsWith("{")) {
            content = content.substring(1);
        }
        if (content.endsWith("}")) {
            content = content.substring(0, content.length() - 1);
        }
        if (content.isBlank()) {
            return values;
        }
        for (String pair : content.split(",")) {
            String[] keyValue = pair.split(":", 2);
            if (keyValue.length != 2) {
                continue;
            }
            String key = unquote(keyValue[0].trim());
            String rawValue = keyValue[1].trim();
            if (rawValue.startsWith("\"")) {
                values.put(key, unquote(rawValue));
            } else {
                values.put(key, Long.parseLong(rawValue));
            }
        }
        return values;
    }

    private String toJson(Map<String, Object> claims) {
        StringBuilder builder = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Object> entry : claims.entrySet()) {
            if (!first) {
                builder.append(',');
            }
            first = false;
            builder.append('"').append(escape(entry.getKey())).append('"').append(':');
            Object value = entry.getValue();
            if (value instanceof Number) {
                builder.append(value);
            } else {
                builder.append('"').append(escape(String.valueOf(value))).append('"');
            }
        }
        return builder.append('}').toString();
    }

    private String escape(String value) {
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private String unquote(String value) {
        String result = value;
        if (result.startsWith("\"")) {
            result = result.substring(1);
        }
        if (result.endsWith("\"")) {
            result = result.substring(0, result.length() - 1);
        }
        return result.replace("\\\"", "\"").replace("\\\\", "\\");
    }

    private String base64Url(byte[] value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value);
    }

    private boolean constantTimeEquals(String first, String second) {
        return MessageDigestSafeEquals.equals(first.getBytes(StandardCharsets.UTF_8), second.getBytes(StandardCharsets.UTF_8));
    }
}
