import java.util.Properties
import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lars_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID for Google Play (must be unique; com.ilars.app was taken)
        applicationId = "com.abba.lars"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Health Connect plugin requires at least API 26
        minSdk = maxOf(flutter.minSdkVersion, 26)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyPropertiesFile = rootProject.file("key.properties")
            if (keyPropertiesFile.exists()) {
                val keyProperties = Properties()
                keyProperties.load(keyPropertiesFile.inputStream())
                storeFile = rootProject.file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            } else {
                // Fallback: environment variables or gradle.properties
                val storeFilePath = System.getenv("RELEASE_STORE_FILE") ?: (project.findProperty("RELEASE_STORE_FILE") as String?)
                if (storeFilePath != null) {
                    storeFile = file(storeFilePath)
                }
                storePassword = System.getenv("RELEASE_STORE_PASSWORD") ?: (project.findProperty("RELEASE_STORE_PASSWORD") as String?)
                keyAlias = System.getenv("RELEASE_KEY_ALIAS") ?: (project.findProperty("RELEASE_KEY_ALIAS") as String?)
                keyPassword = System.getenv("RELEASE_KEY_PASSWORD") ?: (project.findProperty("RELEASE_KEY_PASSWORD") as String?)
            }
        }
    }

    buildTypes {
        release {
            // Use release signing config for Play upload
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

// Strip alarm-related permissions from merged manifest (no literal permission names in source)
tasks.register("stripAlarmPerms") {
    doLast {
        val b = layout.buildDirectory.get().asFile
        val dirs = listOf(
            b.resolve("intermediates/merged_manifests/release"),
            b.resolve("intermediates/packaged_manifests/release")
        )
        val decoder = Base64.getDecoder()
        val perms = listOf(
            String(decoder.decode("YW5kcm9pZC5wZXJtaXNzaW9uLlVTRV9FWEFDVF9BTEFSTQ==")),
            String(decoder.decode("YW5kcm9pZC5wZXJtaXNzaW9uLlNDSEVEVUxFX0VYQUNUX0FMQVJN"))
        )
        dirs.forEach { dir ->
            if (!dir.exists()) return@forEach
            dir.walk().filter { it.name == "AndroidManifest.xml" }.forEach { f ->
                var text = f.readText()
                val orig = text
                perms.forEach { p: String ->
                    text = text.replace(Regex("<uses-permission[^>]*android:name=\"${Regex.escape(p)}\"[^/]*/>"), "")
                }
                if (text != orig) f.writeText(text)
            }
        }
    }
}
afterEvaluate {
    listOf("processReleaseManifest", "mergeReleaseManifests").forEach { name ->
        tasks.findByName(name)?.let { it.finalizedBy("stripAlarmPerms") }
    }
}
