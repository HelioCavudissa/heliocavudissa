//
//  CDMovie+CoreDataProperties.m
//  FLAGProj
//
//  Created by Pedro Brito on 07/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//
//

#import "CDMovie+CoreDataProperties.h"

@implementation CDMovie (CoreDataProperties)

+ (NSFetchRequest<CDMovie *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDMovie"];
}

@dynamic movie_id;
@dynamic title;
@dynamic poster_path;
@dynamic overview;
@dynamic release_date;
@dynamic original_title;
@dynamic original_language;
@dynamic backdrop_path;
@dynamic popularity;
@dynamic vote_count;
@dynamic vote_average;

@end
