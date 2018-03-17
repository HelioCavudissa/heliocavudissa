//
//  TVSerie.m
//  FLAGProj
//
//  Created by Hélio Cavudissa on 15/03/18.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "TVSerie.h"

@implementation TVSerie

-(instancetype)initWithDictionary:(NSDictionary*)obj {
    self = [super init];
    if(self) {
        self.tvSerieId = [obj objectForKey:@"id"];
        self.poster_path = [obj objectForKey:@"poster_path"];
        self.overview = [obj objectForKey:@"overview"];
        self.firstAirDate = [obj objectForKey:@"first_air_date"];
        self.name = [obj objectForKey:@"name"];
        self.original_language = [obj objectForKey:@"original_language"];
        self.backdrop_path = [obj objectForKey:@"backdrop_path"];
        self.popularity = [obj objectForKey:@"popularity"];
        self.vote_count = [obj objectForKey:@"vote_count"];
        self.vote_average = [obj objectForKey:@"vote_average"];
    }
    return self;
}


-(instancetype)initWithCDModel:(CDTVSerie*)cdObj {
    self = [super init];
    if(self) {
        self.tvSerieId = [NSNumber numberWithInteger:cdObj.tvSerieId];
        self.poster_path = cdObj.poster_path;
        self.overview = cdObj.overview;
        self.firstAirDate = cdObj.firstAirDate;
        self.original_language = cdObj.original_language;
        self.name = cdObj.name;
        self.backdrop_path = cdObj.backdrop_path;
        self.popularity = [NSNumber numberWithInteger:cdObj.popularity];
        self.vote_count = [NSNumber numberWithInteger:cdObj.vote_count];
        self.vote_average = [NSNumber numberWithDouble:cdObj.vote_average];
    }
    return self;
}




@end
