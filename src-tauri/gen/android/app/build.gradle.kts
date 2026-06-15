plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("kotlin-kapt")
    id("com.github.ben-manes.versions")
}

android {
    namespace = "com.quicknurse.app"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.quicknurse.app"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release") // Configure in local.properties or CI
        }
        debug {
            isMinifyEnabled = false
            isDebuggable = true
            applicationIdSuffix = ".debug"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = false
        viewBinding = true
        dataBinding = true
    }

    packagingOptions {
        resources {
            excludes += "/META-INF/*"
        }
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")

    // Tauri dependencies
    implementation("org.tauri:tauri-runtime:2.0.0")
    implementation("org.tauri:tauri-bindings:2.0.0")

    // SQLCipher for encrypted database
    implementation("net.zetetic:android-database-sqlcipher:4.6.1")

    // Biometrics
    implementation("androidx.biometric:biometric:1.2.0-alpha04")

    // Notifications
    implementation("androidx.core:core:1.13.1")

    // Room (optional, for migrations)
    // implementation("androidx.room:room-runtime:2.6.1")
    // kapt("androidx.room:room-compiler:2.6.1")

    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
}