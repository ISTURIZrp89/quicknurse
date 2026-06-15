# QuickNurse ProGuard Rules

# Keep Tauri classes
-keep class org.tauri.** { *; }
-keep class org.tauri.app.** { *; }

# Keep application class
-keep class com.quicknurse.app.** { *; }

# Keep SQLCipher
-keep class net.sqlcipher.** { *; }

# Keep Biometric API
-keep class androidx.biometric.** { *; }

# Keep Kotlin stdlib
-keep class kotlin.** { *; }

# Keep serialization
-keep class kotlinx.serialization.** { *; }

# Keep Room (if used)
-keep class androidx.room.** { *; }

# Keep WebView JNI
-keep class org.chromium.** { *; }

# Don't obfuscate resource names
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}