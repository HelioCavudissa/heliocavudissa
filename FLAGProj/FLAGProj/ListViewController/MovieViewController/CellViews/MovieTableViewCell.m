//
//  MovieTableViewCell.m
//  FLAGProj
//
//  Created by Admin on 08/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "MovieTableViewCell.h"

@interface MovieTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *voteAvgLabel;




@end

@implementation MovieTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellValues:(NSString*)title andreleaseDate:(NSString*)date andVoteAvg:(NSString*)vote {
    [self.titleLabel setText:title];
    [self.releaseDateLabel setText:date];
    [self.voteAvgLabel setText:vote];

}



@end
