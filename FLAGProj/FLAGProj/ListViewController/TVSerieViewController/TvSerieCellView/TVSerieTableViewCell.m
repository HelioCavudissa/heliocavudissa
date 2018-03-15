//
//  TVSerieTableViewCell.m
//  FLAGProj
//
//  Created by Formando on 10/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "TVSerieTableViewCell.h"


@interface TVSerieTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstAirDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *voteAvgLabel;




@end

@implementation TVSerieTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setCellValues:(TVSerie*)tvserie{
    [self.nameLabel setText:tvserie.name];
    [self.firstAirDateLabel setText:tvserie.firstAirDate];
    [self.voteAvgLabel setText:tvserie.vote_average.stringValue];
    
}



@end

