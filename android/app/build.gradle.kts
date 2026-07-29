plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nextgeni.meter_pulse"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nextgeni.meter_pulse"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // ML Kit text recognition and Isar require API 23+.
        // 26, not flutter.minSdkVersion (24): tflite_flutter's native TensorFlow
        // Lite binaries require API 26. Raising the floor is a real tradeoff —
        // it drops Android 5–7 devices — but the seven-segment classifier is the
        // only thing that makes meter scanning reliable, and ML Kit already
        // required 23.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Deliberately signed with the debug keystore (~/.android/debug.keystore,
            // cert SHA-256 D1:7E:2E:...:D1:F8, valid to 2056). The app installed on
            // real devices carries that certificate, and Android only accepts an
            // update signed with the *same* one. Switching to a fresh keystore would
            // fail with INSTALL_FAILED_UPDATE_INCOMPATIBLE and force an uninstall,
            // which deletes the on-device Isar database (readings, bills, photos).
            // Back that keystore up; losing it means no future update can be
            // installed over an existing copy of the app. Only move to a dedicated
            // keystore alongside a deliberate export/reinstall/import migration.
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring for flutter_local_notifications.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
