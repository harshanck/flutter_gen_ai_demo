import 'dart:io';

class Model {
  final String name;
  final String path;
  List<String> files;

  Model(this.name, this.path, this.files);
}

class Models {
  static Model? model;

  static var llama3_2 = Model("Llama 3.2 1B", "Llama_3_2_1B", [
    'https://huggingface.co/onnx-community/Llama-3.2-1B-Instruct-ONNX/resolve/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/config.json',
    'https://huggingface.co/onnx-community/Llama-3.2-1B-Instruct-ONNX/resolve/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/genai_config.json',
    'https://huggingface.co/onnx-community/Llama-3.2-1B-Instruct-ONNX/resolve/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/model.onnx',
    'https://huggingface.co/onnx-community/Llama-3.2-1B-Instruct-ONNX/resolve/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/model.onnx.data',
    'https://huggingface.co/onnx-community/Llama-3.2-1B-Instruct-ONNX/resolve/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/special_tokens_map.json',
    'https://huggingface.co/onnx-community/Llama-3.2-1B-Instruct-ONNX/resolve/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/tokenizer.json',
    'https://huggingface.co/onnx-community/Llama-3.2-1B-Instruct-ONNX/resolve/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/tokenizer_config.json',
  ]);

  static var phi3_5Mini = Model("Phi-3.5-Mini", "Phi35Mini", [
    'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-awq-block-128-acc-level-4/config.json',
    'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-awq-block-128-acc-level-4/genai_config.json',
    'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-awq-block-128-acc-level-4/phi-3.5-mini-instruct-cpu-int4-awq-block-128-acc-level-4.onnx',
    'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-awq-block-128-acc-level-4/phi-3.5-mini-instruct-cpu-int4-awq-block-128-acc-level-4.onnx.data',
    'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-awq-block-128-acc-level-4/special_tokens_map.json',
    'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-awq-block-128-acc-level-4/tokenizer.json',
    'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-awq-block-128-acc-level-4/tokenizer_config.json',
  ]);

  static init() {
    if (Platform.isAndroid) {
      model = Models.phi3_5Mini;
    }
    model = Models.llama3_2;
  }

  static setModel(Model m) {
    model = m;
  }

  static Model getModel() {
    if (model == null) {
      init();
    }
    return model!;
  }
}
