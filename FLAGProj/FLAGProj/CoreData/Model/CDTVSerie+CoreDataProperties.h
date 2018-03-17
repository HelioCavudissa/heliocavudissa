//
//  CDTVSerie+CoreDataProperties.h
//  FLAGProj
//
//  Created by Admin on 17/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//
//

#import "CDTVSerie+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDTVSerie (CoreDataProperties)

+ (NSFetchRequest<CDTVSerie *> *)fetchRequest;

@property (nonatomic) int64_t tvSerieId;
@property (nullable, nonatomic, copy) NSString *poster_path;
@property (nullable, nonatomic, copy) NSString *overview;
@property (nullable, nonatomic, copy) NSString *firstAirDate;
@property (nonatomic) int64_t popularity;
@property (nullable, nonatomic, copy) NSString *original_language;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *backdrop_path;
@property (nullable, nonatomic, copy) NSString *originalCountry;
@property (nonatomic) int64_t vote_count;
@property (nullable, nonatomic, copy) NSDecimalNumber *vote_average;

@end

NS_ASSUME_NONNULL_END
