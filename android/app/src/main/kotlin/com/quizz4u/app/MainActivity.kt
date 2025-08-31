package com.quizz4u.app

import io.flutter.embedding.android.FlutterActivity
import androidx.core.view.WindowCompat
import android.os.Bundle

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable Edge-to-Edge display for Android 15+ compatibility
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
} 