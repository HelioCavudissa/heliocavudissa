//
//  MovieDetail.m
//  FLAGProj
//
//  Created by Hélio Cavudissa on 31/03/18.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "MovieDetail.h"
@interface MovieDetail()
@end

@implementation MovieDetail

-(instancetype)initWithDictionary:(NSDictionary*)obj {
    self = [super init];
    if(self) {
        self.homepage= [obj objectForKey:@"homepage"];
    
    }
    return self;
}


@end
