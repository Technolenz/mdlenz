import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle Plugin
    id("com.google.gms.google-services") // Google Services Plugin
}

android {
    namespace = "com.technolenz.mdlenz"
    compileSdk = 35
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.technolenz.mdlenz" // Unique Application ID
        minSdk = 23 // Minimum SDK version
        targetSdk = flutter.targetSdkVersion // Target SDK version
        versionCode = flutter.versionCode // Version code for the app
        versionName = flutter.versionName // Version name for the app
    }

    signingConfigs {
        create("release") {
            // Load keystore properties from a file
            val keystorePropertiesFile = rootProject.file("keystore.properties")
            val keystoreProperties = Properties()
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(keystorePropertiesFile.inputStream())
            }

            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = file("android/app/androidkeystore.jks")
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            // Release build configuration
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true // Enable code shrinking and obfuscation
            isShrinkResources = true // Enable resource shrinking
        }
        debug {
            // Debug build configuration
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.." // Flutter module source directory
}
