//
//  MoviesResponse.h
//  FLAGProj
//
//  Created by Pedro Brito on 03/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoviesResponse : NSObject

@property (nonatomic, strong) NSNumber *total_pages;
@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSMutableArray *results;

-(instancetype)initWithDictionary:(NSDictionary*)obj;

@end
