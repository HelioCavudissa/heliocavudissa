//
//  Movie.h
//  FLAGProj
//
//  Created by Pedro Brito on 03/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDMovie+CoreDataClass.h"

@interface Movie : NSObject

@property (nonatomic, strong) NSNumber *movieId;
@property (nonatomic, strong) NSString *poster_path;
@property (nonatomic, strong) NSString *overview;
@property (nonatomic, strong) NSString *release_date;
@property (nonatomic, strong) NSString *original_title;
@property (nonatomic, strong) NSString *original_language;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *backdrop_path;
@property (nonatomic, strong) NSNumber *popularity;
@property (nonatomic, strong) NSNumber *vote_count;
@property (nonatomic, strong) NSNumber *vote_average;

-(instancetype)initWithDictionary:(NSDictionary*)obj;
-(instancetype)initWithCDModel:(CDMovie*)cdObj;

@end
