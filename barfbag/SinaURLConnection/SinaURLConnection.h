#import <Foundation/Foundation.h>

typedef void (^SinaURLConnectionCompletionBlock)        (NSData *data, NSURLResponse *response);
typedef void (^SinaURLConnectionErrorBlock)              (NSError *error);
typedef void (^SinaURLConnectionUploadProgressBlock)     (float progress);
typedef void (^SinaURLConnectionDownloadProgressBlock)   (float progress);
typedef void (^SinaURLConnectionCancelBlock)             (float progress);


@interface SinaURLConnection : NSObject 

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request 
                   completionBlock:(SinaURLConnectionCompletionBlock)completionBlock
                        errorBlock:(SinaURLConnectionErrorBlock)errorBlock
               uploadProgressBlock:(SinaURLConnectionUploadProgressBlock)uploadBlock
             downloadProgressBlock:(SinaURLConnectionDownloadProgressBlock)downloadBlock
                       cancelBlock:(SinaURLConnectionCancelBlock)cancelBlock;

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request
                   completionBlock:(SinaURLConnectionCompletionBlock)completionBlock 
                        errorBlock:(SinaURLConnectionErrorBlock)errorBlock;

+ (void)asyncConnectionWithURLString:(NSString *)urlString
                     completionBlock:(SinaURLConnectionCompletionBlock)completionBlock 
                          errorBlock:(SinaURLConnectionErrorBlock)errorBlock;

@end