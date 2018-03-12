//
//  HttpRequestsUtility.h
//  FLAGProj
//
//  Created by Pedro Brito on 03/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HttpRequestsUtility : NSObject
//build parameterized request
+(NSURL*)buildRequestURL:(NSString*)baseUrl andPath:(NSString*)path withQueryParams:(NSDictionary*)params;

//execute GET request
+(void)executeGETRequest:(NSURL*)url withCompletion:(void (^) (id, NSError*))completionHandler;

//execute Image Download task
+(void)executeDownloadImage:(NSURL*)imgUrl withCompletion:(void (^) (UIImage*,NSError*))completionHandler;
+(void)executeDownloadImage:(NSURL*)imgUrl intoImageView:(UIImageView*)imageView withErrorHandler:(void (^) (NSError*))failure;

@end
