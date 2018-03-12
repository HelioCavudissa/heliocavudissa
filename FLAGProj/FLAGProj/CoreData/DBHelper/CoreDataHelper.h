//
//  CoreDataHelper.h
//  aula_8
//
//  Created by Pedro Brito on 03/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"

@interface CoreDataHelper : NSObject

-(void)saveOrUpdateMovieList:(NSArray*)moviesList;
-(BOOL)saveOrUpdateMovie:(Movie*)movie;
-(void)loadMoviesPage:(NSInteger)page withSize:(NSInteger)pageSize withCompletionHandler:(void (^) (NSMutableArray*, NSError*))completion;

@end
