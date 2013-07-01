//
//  HTTPDownloader.m
//  VOA
//
//  Created by yangzexin on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HTTPDownloader.h"

@interface HTTPDownloader ()

@property(nonatomic, copy)NSString *filePathForSave;
@property(nonatomic, retain)NSURLRequest *request;
@property(nonatomic, retain)NSFileHandle *fileHandle;
@property(nonatomic, retain)NSURLConnection *urlConnection;
@property(nonatomic, assign)long long contentDownloaded;
@property(nonatomic, assign)long long contentLength;

- (void)notifyDownloadDidStarted;
- (void)notifyDownloadDidFinished;
- (void)notifyDownloading;
- (void)notifyDownloadErrored:(NSError *)error;

@end

@implementation HTTPDownloader

@synthesize delegate = _delegate;
@synthesize URLString = _URLString;
@synthesize filePathForSave = _filePathForSave;
@synthesize request = _request;
@synthesize fileHandle = _fileHandle;
@synthesize urlConnection = _urlConnection;
@synthesize contentDownloaded = _contentDownloaded;
@synthesize contentLength = _contentLength;
@synthesize downloading = _downloading;

- (void)dealloc
{
    [_URLString release];
    [_filePathForSave release];
    [_request release];
    [_fileHandle release];
    [_urlConnection release];
    [super dealloc];
}

- (id)initWithURLString:(NSString *)URLString saveToPath:(NSString *)path
{
    self = [super init];
    
    self.URLString = URLString;
    self.filePathForSave = path;
    
    return self;
}

#pragma mark - instance methods
- (void)startDownload
{
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.URLString]];
    if(self.filePathForSave){
        [[NSFileManager defaultManager] createFileAtPath:self.filePathForSave 
                                                contents:nil 
                                              attributes:nil];
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePathForSave];
    }
    self.urlConnection = [[[NSURLConnection alloc] initWithRequest:self.request 
                                                            delegate:self] autorelease];
    [self.urlConnection start];
}

- (void)cancel
{
    [self.urlConnection cancel];
    self.downloading = NO;
}

- (NSString *)pathForSave
{
    return self.filePathForSave;
}

#pragma mark - private methods
- (void)notifyDownloadDidStarted
{
    if([self.delegate respondsToSelector:@selector(HTTPDownloaderDidStarted:)]){
        [self.delegate HTTPDownloaderDidStarted:self];
    }
}
- (void)notifyDownloadDidFinished
{
    if([self.delegate respondsToSelector:@selector(HTTPDownloaderDidFinished:)]){
        [self.delegate HTTPDownloaderDidFinished:self];
    }
}
- (void)notifyDownloading
{
    if([self.delegate respondsToSelector:@selector(HTTPDownloaderDownloading:downloaded:total:)]){
        [self.delegate HTTPDownloaderDownloading:self 
                                      downloaded:self.contentDownloaded 
                                           total:self.contentLength];
    }
}
- (void)notifyDownloadErrored:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(HTTPDownloader:didErrored:)]){
        [self.delegate HTTPDownloader:self didErrored:error];
    }
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.contentLength = [response expectedContentLength];
    self.contentDownloaded = 0;
    self.downloading = YES;
    [self notifyDownloadDidStarted];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.contentLength = 0;
    self.downloading = NO;
    if(self.fileHandle){
        [self.fileHandle closeFile];
    }
    self.fileHandle = nil;
    [self notifyDownloadErrored:error];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(self.fileHandle){
        [self.fileHandle writeData:data];
    }
    self.contentDownloaded += [data length];
    [self notifyDownloading];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.downloading = NO;
    if(self.fileHandle){
        [self.fileHandle closeFile];
    }
    self.fileHandle = nil;
    [self notifyDownloadDidFinished];
}

@end
