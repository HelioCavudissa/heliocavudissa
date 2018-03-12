//
//  MoviesResponse.m
//  FLAGProj
//
//  Created by Pedro Brito on 03/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "MoviesResponse.h"
#import "Movie.h"

@interface MoviesResponse()

@end

@implementation MoviesResponse

-(instancetype)initWithDictionary:(NSDictionary*)obj {
    self = [super init];
    if(self) {
        self.page = [obj objectForKey:@"page"];
        self.total_pages = [obj objectForKey:@"total_pages"];
        NSArray *results = [obj objectForKey:@"results"];
        self.results = [NSMutableArray new];
        for(id item in results) {
            [self.results addObject:[[Movie alloc] initWithDictionary:item]];
        }
    }
    return self;
}

@end
