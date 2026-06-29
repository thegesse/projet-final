package com.goose.notspot.security;

import java.security.MessageDigest;

final class MessageDigestSafeEquals {
    private MessageDigestSafeEquals() {
    }

    static boolean equals(byte[] first, byte[] second) {
        return MessageDigest.isEqual(first, second);
    }
}
