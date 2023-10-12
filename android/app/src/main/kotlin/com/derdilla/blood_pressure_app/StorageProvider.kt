package com.derdilla.blood_pressure_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.content.ContextCompat.startActivity
import androidx.core.content.FileProvider.getUriForFile
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class StorageProvider(private var context: Context,
    private var shareFolder: File
    ): MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL = "bloodPressureApp.derdilla.com/storage"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
         when (call.method) {
             "shareFile" -> shareFile(call.argument<String>("path")!!,
                 call.argument<String>("mimeType")!!, call.argument<String>("name"))
        }
    }

    /**
     * Show the share sheet for saving a file.
     *
     * @param name Used to make the name of the shared file different from the original name.
     */
    private fun shareFile(path: String, mimeType: String, name: String?) {
        val uri = sharableUriFromPath(path, name)

        val sendIntent: Intent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_STREAM, uri)
            type = mimeType
        }

        val shareIntent = Intent.createChooser(sendIntent, null)
        startActivity(context, shareIntent, null)
    }


    private fun sharableUriFromPath(path: String, name: String?): Uri {
        val initialFile = File(path)
        val sharablePath = File(shareFolder, name ?: initialFile.name)
        if (sharablePath.exists()) sharablePath.delete()
        initialFile.copyTo(sharablePath)
        return getUriForFile(context, "com.derdilla.bloodPressureApp.share", sharablePath)
    }
}