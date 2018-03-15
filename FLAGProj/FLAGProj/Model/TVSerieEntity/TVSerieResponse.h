//
//  TVSerieResponse.h
//  FLAGProj
//
//  Created by Hélio Cavudissa on 15/03/18.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVSerieResponse : NSObject
@property (nonatomic, strong) NSNumber *total_pages;
@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSNumber *total_results;
-(instancetype)initWithDictionary:(NSDictionary*)obj;

@end
