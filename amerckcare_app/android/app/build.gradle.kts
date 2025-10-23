plugins {
    id("com.android.application")
    kotlin("android")
    id("com.google.gms.google-services") // <-- apply Google Services plugin
}

android {
    namespace = "com.example.amerckcare_app" // replace with your package name
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.amerckcare_app" // replace with your app ID
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
    implementation("com.google.firebase:firebase-analytics-ktx:21.3.0") // example Firebase dependency
    implementation("com.google.firebase:firebase-auth-ktx:22.3.0") // optional
}

// No need for apply plugin here; already applied in plugins block
