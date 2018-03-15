//
//  DetailViewController.h
//  FLAGProj
//
//  Created by Admin on 08/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

@interface DetailViewController : UIViewController
@property (nonatomic, strong) Movie *movie;
- (IBAction)shareWithinApps:(id)sender;

@end
