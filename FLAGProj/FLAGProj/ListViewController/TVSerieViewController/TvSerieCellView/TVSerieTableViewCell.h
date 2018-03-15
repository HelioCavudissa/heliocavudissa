//
//  TVSerieTableViewCell.h
//  FLAGProj
//
//  Created by Formando on 10/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVSerie.h"

@interface TVSerieTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageLabel;
-(void)setCellValues:(TVSerie*)tvserie;
@end
