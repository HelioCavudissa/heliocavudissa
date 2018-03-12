//
//  Movie.m
//  FLAGProj
//
//  Created by Pedro Brito on 03/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "Movie.h"

@implementation Movie

-(instancetype)initWithDictionary:(NSDictionary*)obj {
    self = [super init];
    if(self) {
        self.movieId = [obj objectForKey:@"id"];
        self.poster_path = [obj objectForKey:@"poster_path"];
        self.overview = [obj objectForKey:@"overview"];
        self.release_date = [obj objectForKey:@"release_date"];
        self.original_title = [obj objectForKey:@"original_title"];
        self.original_language = [obj objectForKey:@"original_language"];
        self.title = [obj objectForKey:@"title"];
        self.backdrop_path = [obj objectForKey:@"backdrop_path"];
        self.popularity = [obj objectForKey:@"popularity"];
        self.vote_count = [obj objectForKey:@"vote_count"];
        self.vote_average = [obj objectForKey:@"vote_average"];
    }
    return self;
}

-(instancetype)initWithCDModel:(CDMovie*)cdObj {
    self = [super init];
    if(self) {
        self.movieId = [NSNumber numberWithInteger:cdObj.movie_id];
        self.poster_path = cdObj.poster_path;
        self.overview = cdObj.overview;
        self.release_date = cdObj.release_date;
        self.original_title = cdObj.original_language;
        self.original_language = cdObj.original_language;
        self.title = cdObj.title;
        self.backdrop_path = cdObj.backdrop_path;
        self.popularity = [NSNumber numberWithInteger:cdObj.popularity];
        self.vote_count = [NSNumber numberWithInteger:cdObj.vote_count];
        self.vote_average = [NSNumber numberWithDouble:cdObj.vote_average];
    }
    return self;
}

@end
