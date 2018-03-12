//
//  CDMovie+CoreDataProperties.h
//  FLAGProj
//
//  Created by Pedro Brito on 07/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//
//

#import "CDMovie+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDMovie (CoreDataProperties)

+ (NSFetchRequest<CDMovie *> *)fetchRequest;

@property (nonatomic) int64_t movie_id;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *poster_path;
@property (nullable, nonatomic, copy) NSString *overview;
@property (nullable, nonatomic, copy) NSString *release_date;
@property (nullable, nonatomic, copy) NSString *original_title;
@property (nullable, nonatomic, copy) NSString *original_language;
@property (nullable, nonatomic, copy) NSString *backdrop_path;
@property (nonatomic) int64_t popularity;
@property (nonatomic) int64_t vote_count;
@property (nonatomic) double vote_average;

@end

NS_ASSUME_NONNULL_END
