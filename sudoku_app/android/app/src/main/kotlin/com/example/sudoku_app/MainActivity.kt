package com.example.sudoku_app

import android.content.ClipData
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
  private val channelName = "com.sudoku/menu"
  var pendingFileBytes: ByteArray? = null
  private var channel: MethodChannel? = null
  private val mainHandler = Handler(Looper.getMainLooper())

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
    channel?.setMethodCallHandler { call, result ->
      when (call.method) {
        "getPendingFile" -> {
          result.success(pendingFileBytes)
          pendingFileBytes = null
        }
        "shareGameFile" -> {
          val bytes = call.arguments as ByteArray
          shareFile(bytes)
          result.success(null)
        }
        else -> result.notImplemented()
      }
    }
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    pendingFileBytes = bytesFromIntent(intent)
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
    val bytes = bytesFromIntent(intent) ?: return
    pendingFileBytes = bytes
    mainHandler.postDelayed({
      if (pendingFileBytes != null) {
        val b = pendingFileBytes!!
        pendingFileBytes = null
        channel?.invokeMethod("openGameFile", b)
      }
    }, 300)
  }

  private fun bytesFromIntent(intent: Intent?): ByteArray? {
    if (intent == null) return null
    return when (intent.action) {
      "com.example.sudoku_app.OPEN_FILE" ->
        intent.getByteArrayExtra("fileBytes")
      Intent.ACTION_VIEW ->
        readBytes()
      else -> null
    }
  }

  private fun shareFile(bytes: ByteArray) {
    val file = File(cacheDir, "sudoku_game.sudoku")
    file.writeBytes(bytes)
    val uri = FileProvider.getUriForFile(
      this,
      "${applicationContext.packageName}.sudoku.fileprovider",
      file,
    )
    val shareIntent = Intent(Intent.ACTION_SEND).apply {
      type = "application/octet-stream"
      putExtra(Intent.EXTRA_STREAM, uri)
      clipData = ClipData.newRawUri("Game file", uri)
      addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }
    startActivity(Intent.createChooser(shareIntent, null))
  }

  private fun readBytes(): ByteArray? {
    val uri = intent?.data ?: return null
    return try {
      contentResolver.openInputStream(uri)?.use { it.readBytes() }
    } catch (_: Exception) {
      null
    }
  }
}
