//
//  GenAIWrapper.m
//  Runner
//
//  Created by HarshaNCK on 2024-10-12.
//

#import "GenAIWrapper.h"
#include "ort_genai.h"
#include "ort_genai_c.h"

@implementation GenAIWrapper {
    std::unique_ptr<OgaModel> _model;
    std::unique_ptr<OgaTokenizer> _tokenizer;
}

- (BOOL)load:(NSString *)modelPath error:(NSError **)error {
    @try {
        const char* modelPathCStr = [modelPath UTF8String];
        _model = OgaModel::Create(modelPathCStr);
        _tokenizer = OgaTokenizer::Create(*_model);
        return true;
    } @catch (...) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.example.flutter.flutter_gen_ai_demo.GenAIWrapper"
                                         code:1003
                                     userInfo:@{NSLocalizedDescriptionKey : @"Unknown error occurred while loading the model."}];
        }
        return false;
    }
}


- (BOOL)inference:(nonnull NSString *)prompt withParams:(NSDictionary<NSString *, NSNumber *> *)params {
    auto sequences = OgaSequences::Create();
    
    _tokenizer->Encode([prompt UTF8String], *sequences);

    auto ogaParams = OgaGeneratorParams::Create(*_model);
    
    ogaParams->SetSearchOption("max_length", 1000);

    for (NSString *key in params) {
        id value = params[key];
        if ([value isKindOfClass:[NSNumber class]]) {
            ogaParams->SetSearchOption([key UTF8String], [(NSNumber *)value intValue]);
        }
    }
    
    ogaParams->SetInputSequences(*sequences);
    
    auto tokenizer_stream = OgaTokenizerStream::Create(*_tokenizer);
    auto generator = OgaGenerator::Create(*_model, *ogaParams);

    while (!generator->IsDone()) {
        generator->ComputeLogits();
        generator->GenerateNextToken();
        const int32_t* seq = generator->GetSequenceData(0);
        size_t seq_len = generator->GetSequenceCount(0);
        const char* decode_tokens = tokenizer_stream->Decode(seq[seq_len - 1]);

        NSString* decodedTokenString = [NSString stringWithUTF8String:decode_tokens];
 
        if (self.delegate && [self.delegate respondsToSelector:@selector(didGenerateToken:)]) {
            [self.delegate didGenerateToken:decodedTokenString];
        }
    }
    return true;
}

- (void)unload {
    _tokenizer.reset();
    _model.reset();
}

@end
