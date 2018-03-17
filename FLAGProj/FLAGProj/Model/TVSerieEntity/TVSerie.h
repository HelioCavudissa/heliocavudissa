//
//  TVSerie.h
//  FLAGProj
//
//  Created by Hélio Cavudissa on 15/03/18.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDTVSerie+CoreDataClass.h"

@interface TVSerie : NSObject
@property (nonatomic, strong) NSNumber *tvSerieId;
@property (nonatomic, strong) NSString *poster_path;
@property (nonatomic, strong) NSString *overview;
@property (nonatomic, strong) NSString *firstAirDate;
@property (nonatomic, strong) NSNumber *popularity;
@property (nonatomic, strong) NSString *original_language;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *backdrop_path;
@property (nonatomic, strong) NSString *originalCountry;
@property (nonatomic, strong) NSNumber *vote_count;
@property (nonatomic, strong) NSNumber *vote_average;
-(instancetype)initWithDictionary:(NSDictionary*)obj;
-(instancetype)initWithCDModel:(CDTVSerie*)cdObj;

@end
