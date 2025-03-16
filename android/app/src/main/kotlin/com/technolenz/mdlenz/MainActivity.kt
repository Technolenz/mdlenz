package com.technolenz.mdlenz

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.technolenz.mdlenz/file"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupMethodChannel(flutterEngine)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun setupMethodChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestFileContent" -> {
                    handleIntent(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun handleIntent(intent: Intent) {
        val action = intent.action
        val uri = intent.data

        if (Intent.ACTION_VIEW == action && uri != null) {
            Thread {
                try {
                    val fileContent = readFileContent(uri)
                    runOnUiThread {
                        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                            .invokeMethod("openFile", fileContent)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    runOnUiThread {
                        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                            .invokeMethod("openFileError", e.message)
                    }
                }
            }.start()
        }
    }

    private fun readFileContent(uri: Uri): String {
        val content = StringBuilder()
        var inputStream: InputStream? = null
        var reader: BufferedReader? = null

        try {
            inputStream = contentResolver.openInputStream(uri)
            reader = BufferedReader(InputStreamReader(inputStream))
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                content.append(line).append("\n")
            }
        } catch (e: Exception) {
            throw e // Re-throw the exception to handle it in the calling method
        } finally {
            try {
                reader?.close()
                inputStream?.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        return content.toString()
    }
}