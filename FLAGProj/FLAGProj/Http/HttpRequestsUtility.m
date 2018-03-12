//
//  HttpRequestsUtility.m
//  FLAGProj
//
//  Created by Pedro Brito on 03/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "HttpRequestsUtility.h"

@implementation HttpRequestsUtility


+(NSURL*)buildRequestURL:(NSString*)baseUrl andPath:(NSString*)path withQueryParams:(NSDictionary*)params {
    NSString *requestPath = baseUrl;
    if(path != nil) {
        requestPath = [NSString stringWithFormat:@"%@/%@", baseUrl, path];
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithString:requestPath];
    NSMutableArray *queryParams = [NSMutableArray new];
    
    if(params != nil && params.allKeys.count > 0) {
        for(NSString *key in params.allKeys) {
            NSString *value = params[key];
            [queryParams addObject:[NSURLQueryItem queryItemWithName:key value:value]];
        }
    }
    
    components.queryItems = queryParams;
    NSURL *url = components.URL;
    return url;
}

+(void)executeGETRequest:(NSURL*)url withCompletion:(void (^) (id, NSError*))completionHandler {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (data == nil) {
                                          completionHandler(nil, error);
                                      } else {
                                          NSError *conversionError;
                                          id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
                                          completionHandler(object, conversionError);
                                      }
                                  }];
    [task resume];
    
}

+(void)executeDownloadImage:(NSURL*)imgUrl withCompletion:(void (^) (UIImage*,NSError*))completionHandler {
    NSMutableURLRequest *imgRequest = [[NSMutableURLRequest alloc] init];
    [imgRequest setURL:imgUrl];
    [imgRequest setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:imgRequest
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (data == nil) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completionHandler(nil, error);
                                          });
                                      } else {
                                          UIImage *img = [UIImage imageWithData:data];
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completionHandler(img, nil);
                                          });
                                      }
                                  }];
    [task resume];
}

+(void)executeDownloadImage:(NSURL*)imgUrl intoImageView:(UIImageView*)imageView withErrorHandler:(void (^) (NSError*))failure {
    
    __weak UIImageView *weakImgRef = imageView;
    [HttpRequestsUtility executeDownloadImage:imgUrl withCompletion:^(UIImage *downloadedImage, NSError *error) {
        if(downloadedImage) {
            weakImgRef.image = downloadedImage;
        }
        
        if(error) {
            failure(error);
        }
    }];
}

@end
