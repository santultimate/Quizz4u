package com.quizz4u.app

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * FlutterFragmentActivity + enableEdgeToEdge() for Android 15+ Play Console
 * compatibility (avoids deprecated Window status/navigation bar color APIs).
 */
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }
}
