//
//  CDTVSerie+CoreDataProperties.m
//  FLAGProj
//
//  Created by Admin on 17/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//
//

#import "CDTVSerie+CoreDataProperties.h"

@implementation CDTVSerie (CoreDataProperties)

+ (NSFetchRequest<CDTVSerie *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDTVSerie"];
}

@dynamic tvSerieId;
@dynamic poster_path;
@dynamic overview;
@dynamic firstAirDate;
@dynamic popularity;
@dynamic original_language;
@dynamic name;
@dynamic backdrop_path;
@dynamic originalCountry;
@dynamic vote_count;
@dynamic vote_average;

@end
