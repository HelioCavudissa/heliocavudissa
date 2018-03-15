//
//  DetailTVSerieViewController.h
//  FLAGProj
//
//  Created by Hélio Cavudissa on 15/03/18.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVSerie.h"

@interface DetailTVSerieViewController : UIViewController
@property (nonatomic, strong) TVSerie *tvSerie;
- (IBAction)shareWithinApps:(id)sender;

@end
