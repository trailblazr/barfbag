#import "SinaURLConnection.h"

@interface SinaURLConnection () {
    NSURLConnection *connection;
    NSURLRequest    *request;
    NSMutableData   *data;
    NSURLResponse   *response;
    long long       downloadSize;
    
    SinaURLConnectionCompletionBlock completionBlock;
    SinaURLConnectionErrorBlock errorBlock;
    SinaURLConnectionUploadProgressBlock uploadBlock;
    SinaURLConnectionDownloadProgressBlock downloadBlock;
    SinaURLConnectionCancelBlock cancelBlock;
}

- (id)initWithRequest:(NSURLRequest *)request 
      completionBlock:(SinaURLConnectionCompletionBlock)completionBlock
           errorBlock:(SinaURLConnectionErrorBlock)errorBlock
  uploadProgressBlock:(SinaURLConnectionUploadProgressBlock)uploadBlock
downloadProgressBlock:(SinaURLConnectionDownloadProgressBlock)downloadBlock
          cancelBlock:(SinaURLConnectionDownloadProgressBlock)cancelBlock;
- (void)start;

@end

@implementation SinaURLConnection

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request 
                   completionBlock:(SinaURLConnectionCompletionBlock)completionBlock
                        errorBlock:(SinaURLConnectionErrorBlock)errorBlock
               uploadProgressBlock:(SinaURLConnectionUploadProgressBlock)uploadBlock
             downloadProgressBlock:(SinaURLConnectionDownloadProgressBlock)downloadBlock
                       cancelBlock:(SinaURLConnectionCancelBlock)cancelBlock {
    
    SinaURLConnection *connection = [[SinaURLConnection alloc] initWithRequest:request 
                                                       completionBlock:completionBlock 
                                                            errorBlock:errorBlock
                                                   uploadProgressBlock:uploadBlock
                                                 downloadProgressBlock:downloadBlock
                                                           cancelBlock:cancelBlock];
    [connection start];
    [connection release];
}

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request 
                   completionBlock:(SinaURLConnectionCompletionBlock)completionBlock 
                        errorBlock:(SinaURLConnectionErrorBlock)errorBlock {
    [SinaURLConnection asyncConnectionWithRequest:request 
                              completionBlock:completionBlock 
                                   errorBlock:errorBlock 
                          uploadProgressBlock:nil 
                        downloadProgressBlock:nil
                                  cancelBlock:nil];
}

+ (void)asyncConnectionWithURLString:(NSString *)urlString
                     completionBlock:(SinaURLConnectionCompletionBlock)completionBlock 
                          errorBlock:(SinaURLConnectionErrorBlock)errorBlock {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [SinaURLConnection asyncConnectionWithRequest:request 
                              completionBlock:completionBlock 
                                   errorBlock:errorBlock];
}



- (id)initWithRequest:(NSURLRequest *)_request 
      completionBlock:(SinaURLConnectionCompletionBlock)_completionBlock
           errorBlock:(SinaURLConnectionErrorBlock)_errorBlock
  uploadProgressBlock:(SinaURLConnectionUploadProgressBlock)_uploadBlock
downloadProgressBlock:(SinaURLConnectionDownloadProgressBlock)_downloadBlock
          cancelBlock:(SinaURLConnectionCancelBlock)_cancelBlock{
    
    self = [super init];
    if (self) {
        request =           [_request retain];
        completionBlock =   [_completionBlock copy];
        errorBlock =        [_errorBlock copy];
        uploadBlock =       [_uploadBlock copy];
        downloadBlock =     [_downloadBlock copy];
        cancelBlock =       [_cancelBlock copy];
    }
    return self;
}

- (void)dealloc {
    [request release];
    [data release];
    [response release];
    
    [completionBlock release];
    [errorBlock release];
    [uploadBlock release];
    [downloadBlock release];
    [cancelBlock release];
    
    [super dealloc];
}

- (void)start {
    connection  = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    data        = [[NSMutableData alloc] init];
    
    [connection start];    
}




#pragma mark NSURLConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection {
    if(completionBlock) completionBlock(data, response);
}

- (void)connection:(NSURLConnection *)_connection 
  didFailWithError:(NSError *)error {
    if(errorBlock) errorBlock(error);
}

- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSHTTPURLResponse *)_response {
    response = [_response retain];
    downloadSize = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)_data {
    [data appendData:_data];
    
    if (downloadSize != -1) {
        float progress = (float)data.length / (float)downloadSize;
        if(downloadBlock) downloadBlock(progress);
    }
}

- (void)connection:(NSURLConnection *)connection   
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    float progress= (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    if (uploadBlock) uploadBlock(progress);
}


@end
