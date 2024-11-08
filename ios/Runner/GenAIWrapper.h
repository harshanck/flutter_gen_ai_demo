//
//  GenAIWrapper.h
//  Runner
//
//  Created by HarshaNCK on 2024-10-12.
//

#ifndef GenAIWrapper_h
#define GenAIWrapper_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GenAIWrapperDelegate <NSObject>
- (void)didGenerateToken:(NSString *)token;
@end

@interface GenAIWrapper : NSObject

@property (nonatomic, weak) id<GenAIWrapperDelegate> delegate;

- (BOOL)load:(NSString *)modelPath error:(NSError **)error;
- (BOOL)inference:(NSString *)prompt withParams:(NSDictionary<NSString *, NSNumber *> *)params;
- (void)unload;

@end

NS_ASSUME_NONNULL_END

#endif /* GenAIWrapper_h */


