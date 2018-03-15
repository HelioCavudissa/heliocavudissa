//
//  MovieTableViewCell.h
//  FLAGProj
//
//  Created by Admin on 08/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageLabel;
-(void)setCellValues:(NSString*)title andreleaseDate:(NSString*)date andVoteAvg:(NSString*)vote ;

@end
