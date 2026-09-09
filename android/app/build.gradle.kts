plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.zarbulmasal.zarbulmasal"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Keep this stable so installed versions retain their identity and data.
        applicationId = "com.zarbulmasal.zarbulmasal"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        val keystorePath = project.findProperty("KEYSTORE_PATH") as? String
            ?: System.getenv("KEYSTORE_PATH")
        val keystorePassword = project.findProperty("KEYSTORE_PASSWORD") as? String
            ?: System.getenv("KEYSTORE_PASSWORD")
        val keyAlias = project.findProperty("KEY_ALIAS") as? String
            ?: System.getenv("KEY_ALIAS")
        val keyPassword = project.findProperty("KEY_PASSWORD") as? String
            ?: System.getenv("KEY_PASSWORD")

        if (!keystorePath.isNullOrEmpty() && file(keystorePath).exists() &&
            !keystorePassword.isNullOrEmpty() &&
            !keyAlias.isNullOrEmpty() &&
            !keyPassword.isNullOrEmpty()
        ) {
            create("release") {
                storeFile = file(keystorePath)
                storePassword = keystorePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.findByName("release")
            signingConfig = releaseConfig ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
