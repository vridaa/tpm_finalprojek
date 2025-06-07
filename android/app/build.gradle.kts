plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.gift_bouqet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Explicitly set the NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8  // Changed from VERSION_11
        targetCompatibility = JavaVersion.VERSION_1_8  // Changed from VERSION_11
        isCoreLibraryDesugaringEnabled = true  // Added for desugaring
    }

    kotlinOptions {
        jvmTarget = "1.8"  // Changed from VERSION_11
    }

    defaultConfig {
        applicationId = "com.example.gift_bouqet"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // Added if you have many plugins
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")  // Added for desugaring
    implementation("androidx.window:window:1.0.0")  // Recommended for Flutter
    implementation("androidx.window:window-java:1.0.0")  // Recommended for Flutter
}

flutter {
    source = "../.."
}