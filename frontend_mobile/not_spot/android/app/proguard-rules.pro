# 1. Force R8 to compile even if the optional Foldable/Window libraries are missing
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.sidecar.**
-ignorewarnings

# 2. Total structural protection for flutter_secure_storage and its native cryptographic engines
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keepclassmembers class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# 3. Total protection for AndroidX Crypto (where EncryptedSharedPreferences lives)
-keep class androidx.security.crypto.** { *; }
-keepclassmembers class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# 4. Protect all Enum structures globally from losing their runtime reflection array methods
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}