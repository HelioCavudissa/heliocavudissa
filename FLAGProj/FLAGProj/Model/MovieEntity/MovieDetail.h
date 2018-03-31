//
//  MovieDetail.h
//  FLAGProj
//
//  Created by Hélio Cavudissa on 31/03/18.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieDetail : NSObject

@property (nonatomic, strong) NSNumber *movieId;
@property (nonatomic, strong) NSString *homepage;
-(instancetype)initWithDictionary:(NSDictionary*)obj;

@end
