package com.example.flutter.flutter_gen_ai_demo

import ai.onnxruntime.genai.GenAIException
import ai.onnxruntime.genai.Generator
import ai.onnxruntime.genai.GeneratorParams
import ai.onnxruntime.genai.Model
import ai.onnxruntime.genai.Tokenizer
import ai.onnxruntime.genai.Tensor
import ai.onnxruntime.genai.TokenizerStream
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class GenAIWrapper {
    private lateinit var model: Model
    private lateinit var tokenizer: Tokenizer

    fun load(modelPath: String): Boolean {
        return try {
            model = Model(modelPath)
            tokenizer = Tokenizer(model);
            true
        } catch (e: GenAIException) {
            false
        }
    }

    suspend fun inference(
        prompt: String,
        params: Map<String, Double>,
        onTokenGenerated: (String) -> Unit
    ): Boolean {
        if (!::model.isInitialized || !::tokenizer.isInitialized) {
            return false
        }

        return try {
            val stream: TokenizerStream = tokenizer.createStream()
            val generatorParams = GeneratorParams(model)
                .apply {
                setSearchOption("max_length", 1000.0)
                params.forEach { (key, value) ->
                    setSearchOption(key, value)
                }
            }
            val generator = Generator(model, generatorParams)

            try {
                while (!generator.isDone) {

                    generator.appendTokenSequences(tokenizer.encode(prompt))
                    for (tokenId in generator) {
                        var token = stream.decode(tokenId)
                        withContext(Dispatchers.Main) {
                            onTokenGenerated(token)
                        }
                    }

                }
                true
            } finally {
                generator.close()
                generatorParams.close()
                stream.close()
            }
        } catch (e: GenAIException) {
            false
        }
    }

    fun unload() {
        if (::model.isInitialized && ::tokenizer.isInitialized) {
            model.close()
            tokenizer.close()
        }
    }
}
