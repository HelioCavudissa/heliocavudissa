//
//
//  CoreDataHelper.m
//  aula_8
//
//  Created by Pedro Brito on 03/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "CoreDataHelper.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Movie.h"
#import "CDMovie+CoreDataClass.h"

@interface CoreDataHelper ()

@property (nonatomic, strong) NSManagedObjectContext *moc;

@end

@implementation CoreDataHelper

-(instancetype)init {
    self = [super init];
    if(self) {
        self.moc = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) getManagedContext];
    }
    return self;
}


-(void)saveOrUpdateMovieList:(NSArray*)moviesList {
    for(Movie *item in moviesList) {
        [self saveOrUpdateMovie:item];
    }
}

-(void)saveOrUpdateMovie:(Movie*)movie {
    [self.moc performBlock:^{
        NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDMovie"];
        
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"movie_id == %@", movie.movieId.stringValue];
        [userFetch setPredicate:filter];
        
        NSError *cdError = nil;
        
        NSArray *fetchResult = [self.moc executeFetchRequest:userFetch error:&cdError];
        
        CDMovie *cdMovie = nil;
        if(fetchResult.count) {
            cdMovie = fetchResult.firstObject;
        }else {
            cdMovie = [NSEntityDescription insertNewObjectForEntityForName:@"CDMovie" inManagedObjectContext:self.moc];
        }
        
        [cdMovie setMovie_id:movie.movieId.integerValue];
        [cdMovie setTitle:movie.title];\
        if(![movie.poster_path isEqual:[NSNull null]]) {
            [cdMovie setPoster_path:movie.poster_path];
        }
        [cdMovie setOverview:movie.overview];
        [cdMovie setRelease_date:movie.release_date];
        [cdMovie setOriginal_title:movie.original_title];
        [cdMovie setOriginal_language:movie.original_language];
        if(![movie.backdrop_path isEqual:[NSNull null]]) {
            [cdMovie setBackdrop_path:movie.backdrop_path];
        }
        [cdMovie setPopularity:movie.popularity.integerValue];
        [cdMovie setVote_count:movie.vote_count.integerValue];
        [cdMovie setVote_average:movie.vote_average.doubleValue];
        
        [self.moc save:&cdError];
    }];
}

-(void)loadMoviesPage:(NSInteger)page withSize:(NSInteger)pageSize  withCompletionHandler:(void (^) (NSMutableArray*, NSError*))completion {
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *moviesArray = [NSMutableArray new];
        
        NSFetchRequest *moviesFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDMovie"];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey: @"movie_id" ascending:NO];
        [moviesFetch setSortDescriptors:@[sort]];
        
        NSInteger startOffset = page > 0 ? ((page-1)*pageSize) : 0;
        [moviesFetch setFetchOffset:startOffset];
        [moviesFetch setFetchLimit:pageSize];
        NSError *cdError = nil;
        
        NSArray *fetchResult = [self.moc executeFetchRequest:moviesFetch error:&cdError];
        if(fetchResult.count) {
            for(CDMovie *item in fetchResult) {
                [moviesArray addObject:[[Movie alloc] initWithCDModel:item]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(moviesArray, cdError);
        });
    });
}





@end

