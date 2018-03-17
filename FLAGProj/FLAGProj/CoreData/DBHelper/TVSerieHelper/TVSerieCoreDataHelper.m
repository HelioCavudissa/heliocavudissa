//
//  TVSerieCoreDataHelper.m
//  FLAGProj
//
//  Created by Admin on 17/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "TVSerieCoreDataHelper.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "TVSerie.h"
#import "CDTVSerie+CoreDataClass.h"

@interface TVSerieCoreDataHelper()

@property (nonatomic, strong) NSManagedObjectContext *moc;

@end

@implementation TVSerieCoreDataHelper

-(instancetype)init {
    self = [super init];
    if(self) {
        self.moc = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) getManagedContext];
    }
    return self;
}


-(void)saveOrUpdateTVSerieList:(NSArray*)tvSerieList {
    for(TVSerie *item in tvSerieList) {
        [self saveOrUpdateTVSerie:item];
    }
}

-(void)saveOrUpdateTVSerie:(TVSerie*)tvSerie {
    [self.moc performBlock:^{
        NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDTVSerie"];
        
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"tvSerieId == %@", tvSerie.tvSerieId.stringValue];
        [userFetch setPredicate:filter];
        
        NSError *cdError = nil;
        
        NSArray *fetchResult = [self.moc executeFetchRequest:userFetch error:&cdError];
        
        CDTVSerie *cdTVSerie = nil;
        if(fetchResult.count) {
            cdTVSerie = fetchResult.firstObject;
        }else {
            cdTVSerie = [NSEntityDescription insertNewObjectForEntityForName:@"CDTVSerie" inManagedObjectContext:self.moc];
        }
        
        [cdTVSerie setTvSerieId:tvSerie.tvSerieId.integerValue];
        [cdTVSerie setName:tvSerie.name];
        if(![tvSerie.poster_path isEqual:[NSNull null]]) {
            [cdTVSerie setPoster_path:tvSerie.poster_path];
        }
        [cdTVSerie setOverview:tvSerie.overview];
        [cdTVSerie setFirstAirDate:tvSerie.firstAirDate];
        [cdTVSerie setOriginal_language:tvSerie.original_language];
        if(![tvSerie.backdrop_path isEqual:[NSNull null]]) {
            [cdTVSerie setBackdrop_path:tvSerie.backdrop_path];
        }
        [cdTVSerie setPopularity:tvSerie.popularity.integerValue];
        [cdTVSerie setVote_count:tvSerie.vote_count.integerValue];
        [cdTVSerie setVote_average:tvSerie.vote_average.doubleValue];
        
        [self.moc save:&cdError];
    }];
}

-(void)loadTVSeriesPage:(NSInteger)page withSize:(NSInteger)pageSize withCompletionHandler:(void (^) (NSMutableArray*, NSError*))completion {
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *tvSeriesArray = [NSMutableArray new];
        
        NSFetchRequest *tvSeriesFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDTVSerie"];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"tvSerieId" ascending:NO];
        [tvSeriesFetch setSortDescriptors:@[sort]];
        
        NSInteger startOffset = page > 0 ? ((page-1)*pageSize) : 0;
        [tvSeriesFetch setFetchOffset:startOffset];
        [tvSeriesFetch setFetchLimit:pageSize];
        NSError *cdError = nil;
        
        NSArray *fetchResult = [self.moc executeFetchRequest:tvSeriesFetch error:&cdError];
        if(fetchResult.count) {
            for(CDTVSerie *item in fetchResult) {
                [tvSeriesArray addObject:[ [TVSerie alloc]  initWithCDModel:item]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(tvSeriesArray, cdError);
        });
    });
}


@end

