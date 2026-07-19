package com.yourname.meallog_ai

import com.google.mlkit.genai.common.DownloadStatus
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.prompt.Generation
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private val scope = CoroutineScope(Dispatchers.Main)
    private val model by lazy { Generation.getClient() }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "meallog_ai/native_llm",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isSupported" -> scope.launch {
                    try {
                        result.success(model.checkStatus() != FeatureStatus.UNAVAILABLE)
                    } catch (_: Exception) {
                        result.success(false)
                    }
                }
                "prepare" -> scope.launch {
                    try {
                        when (model.checkStatus()) {
                            FeatureStatus.AVAILABLE -> result.success(null)
                            FeatureStatus.DOWNLOADABLE -> {
                                var failure: Exception? = null
                                model.download().collect { status ->
                                    if (status is DownloadStatus.DownloadFailed) failure = status.e
                                }
                                failure?.let { throw it }
                                result.success(null)
                            }
                            else -> result.error("MODEL_NOT_READY", "Gemini Nanoを準備できません", null)
                        }
                    } catch (e: Exception) {
                        result.error("PREPARE_FAILED", e.message, null)
                    }
                }
                "generate" -> scope.launch {
                    val prompt = call.argument<String>("prompt")
                    if (prompt == null) {
                        result.error("INVALID_ARGUMENT", "promptが必要です", null)
                        return@launch
                    }
                    try {
                        val response = model.generateContent(prompt)
                        result.success(response.candidates.firstOrNull()?.text)
                    } catch (e: Exception) {
                        result.error("GENERATION_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
