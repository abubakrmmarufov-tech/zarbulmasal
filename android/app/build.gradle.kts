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
            val releaseBuildRequested = gradle.startParameter.taskNames.any { taskName ->
                taskName.contains("Release", ignoreCase = true)
            }
            // PREVIEW ONLY: -PpreviewDebugSigning=true (or the environment
            // variable ZARBULMASAL_PREVIEW_DEBUG_SIGNING=true) signs a release
            // build with the local debug key so testers can install it. Such
            // an APK can never be uploaded to Google Play or updated by a
            // Play build; without the switch a release still needs the real
            // upload key.
            val previewDebugSigning =
                (project.findProperty("previewDebugSigning") as? String
                    ?: System.getenv("ZARBULMASAL_PREVIEW_DEBUG_SIGNING")) == "true"
            if (releaseConfig != null) {
                signingConfig = releaseConfig
            } else if (previewDebugSigning) {
                logger.warn("PREVIEW BUILD: release signed with the DEBUG key. Not for Google Play.")
                signingConfig = signingConfigs.getByName("debug")
            } else if (releaseBuildRequested) {
                // Keep production artifacts fail-closed, but do not block debug
                // APK validation when CI/local builds have no release secret.
                throw GradleException("Release signing config missing")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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
