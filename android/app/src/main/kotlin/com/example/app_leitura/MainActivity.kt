package com.example.app_leitura

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.UUID
import java.util.concurrent.Executors

/**
 * G09 (D-87): "Abrir com" e "Compartilhar" de EPUB e PDF. O arquivo do `content://` é copiado para
 * `cache/recebidos/` fora da thread principal; o Dart pega a lista ("pendentes") quando o app abre e a cada
 * aviso ("chegaram"), importa e apaga a cópia. Links do login (booknest://) não são arquivo: ficam com o
 * supabase_flutter.
 */
class MainActivity : FlutterActivity() {
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val prontos = mutableListOf<Map<String, String>>()
    private var canal: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        canal = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "booknest/arquivos").also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    "pendentes" -> synchronized(prontos) {
                        result.success(ArrayList(prontos))
                        prontos.clear()
                    }
                    else -> result.notImplemented()
                }
            }
        }
        receber(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        receber(intent)
    }

    private fun receber(intent: Intent?) {
        if (intent == null) return
        val uris = urisDe(intent).filter { it.scheme == "content" || it.scheme == "file" }
        if (uris.isEmpty()) return
        // a mesma intenção não volta a importar se a activity for recriada
        setIntent(Intent(Intent.ACTION_MAIN))
        io.execute {
            val dir = File(cacheDir, "recebidos").apply { mkdirs() }
            for (uri in uris) {
                try {
                    val nome = nomeDe(uri) ?: "livro"
                    val destino = File(dir, UUID.randomUUID().toString())
                    val entrada = contentResolver.openInputStream(uri) ?: continue
                    entrada.use { input -> destino.outputStream().use { input.copyTo(it) } }
                    synchronized(prontos) { prontos.add(mapOf("path" to destino.absolutePath, "name" to nome)) }
                } catch (e: Exception) {
                    // sem permissão de leitura, arquivo que sumiu: ignora (nada é importado)
                }
            }
            main.post { canal?.invokeMethod("chegaram", null) }
        }
    }

    @Suppress("DEPRECATION")
    private fun urisDe(intent: Intent): List<Uri> = when (intent.action) {
        Intent.ACTION_VIEW -> listOfNotNull(intent.data)
        Intent.ACTION_SEND -> listOfNotNull(
            if (Build.VERSION.SDK_INT >= 33) intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            else intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
        )
        Intent.ACTION_SEND_MULTIPLE -> (
            if (Build.VERSION.SDK_INT >= 33) intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)
            else intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
        )?.toList() ?: emptyList()
        else -> emptyList()
    }

    private fun nomeDe(uri: Uri): String? {
        if (uri.scheme == "file") return uri.lastPathSegment
        return try {
            contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c ->
                if (c.moveToFirst()) c.getString(0) else null
            }
        } catch (e: Exception) {
            null
        }
    }
}
