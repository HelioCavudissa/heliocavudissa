//
//  TVSerieResponse.m
//  FLAGProj
//
//  Created by Hélio Cavudissa on 15/03/18.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "TVSerieResponse.h"
#import "TVSerie.h"

@implementation TVSerieResponse

-(instancetype)initWithDictionary:(NSDictionary*)obj {
    self = [super init];
    if(self) {
        self.page = [obj objectForKey:@"page"];
        self.total_pages = [obj objectForKey:@"total_pages"];
        NSArray *results = [obj objectForKey:@"results"];
        self.total_results = [obj objectForKey:@"total_results"];
        self.results = [NSMutableArray new];
        for(id item in results) {
            [self.results addObject:[[TVSerie alloc] initWithDictionary:item]];
        }
    }
    return self;
}

@end
