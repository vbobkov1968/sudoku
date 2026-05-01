package com.example.sudoku_app

import android.app.Activity
import android.content.Intent
import android.os.Bundle

class TrampolineActivity : Activity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    if (intent?.action == Intent.ACTION_VIEW) {
      val bytes = intent?.data?.let { uri ->
        try {
          contentResolver.openInputStream(uri)?.use { it.readBytes() }
        } catch (_: Exception) {
          null
        }
      }
      if (bytes != null) {
        val mainIntent = Intent(this, MainActivity::class.java).apply {
          action = "com.example.sudoku_app.OPEN_FILE"
          putExtra("fileBytes", bytes)
          addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        startActivity(mainIntent)
      }
    }
    finish()
  }
}
