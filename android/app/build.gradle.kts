plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // ИЗМЕНИ ЭТУ СТРОКУ:
    id("com.google.gms.google-services") // без version и apply false
}

android {
    namespace = "com.aimealplanner.ai_meal_planner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.aimealplanner.ai_meal_planner"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ✅ ДОБАВЬТЕ ЭТИ ЗАВИСИМОСТИ
dependencies {
    // Для AdMob
    implementation("com.google.android.gms:play-services-ads:23.0.0")

    // Для Firebase (если используете)
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}