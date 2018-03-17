//
//  TVSerieCoreDataHelper.h
//  FLAGProj
//
//  Created by Admin on 17/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVSerie.h"

@interface TVSerieCoreDataHelper : NSObject
-(void)saveOrUpdateTVSerieList:(NSArray*)tvSerieList;
-(void)saveOrUpdateTVSerie:(TVSerie*)tvSerie;
-(void)loadTVSeriesPage:(NSInteger)page withSize:(NSInteger)pageSize withCompletionHandler:(void (^) (NSMutableArray*, NSError*))completion;

@end
