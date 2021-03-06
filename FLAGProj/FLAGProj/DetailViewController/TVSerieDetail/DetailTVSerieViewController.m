//
//  DetailTVSerieViewController.m
//  FLAGProj
//
//  Created by Hélio Cavudissa on 15/03/18.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "DetailTVSerieViewController.h"
#import "HttpRequestsUtility.h"
#import "Configs.h"
#import "MoviesResponse.h"

@interface DetailTVSerieViewController ()
//declaração das Outlets ligadas aos elementos mutáveis do ecrã
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *overviewLabel;

@property (weak, nonatomic) IBOutlet UILabel *voteAvgLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseLabel;
@property (weak, nonatomic) IBOutlet UIImageView *downloadImage;
@property (weak, nonatomic) NSString* homepage;


@end

@implementation DetailTVSerieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.titleLabel setText:self.tvSerie.name  ];
    [self.overviewLabel setText:self.tvSerie.overview];
    [self.voteAvgLabel setText:self.tvSerie.vote_average.stringValue];
    [self.releaseLabel setText:self.tvSerie.firstAirDate ];
    [self doSearchRequest:self.tvSerie.tvSerieId];
    
    
    
    //create an image URL to download
    NSURL *imgRequestURL = [HttpRequestsUtility buildRequestURL:@"https://image.tmdb.org/t/p/w500/" andPath: self.tvSerie.poster_path withQueryParams:nil];
    
    //execute download image and set UI image view resource in completion handler, useful for example when you need to work the image before applying it to the UIImageView
    [HttpRequestsUtility executeDownloadImage:imgRequestURL withCompletion:^(UIImage *image, NSError *error) {
        //this completion handler code is executing in foreground main thread
        if(error == nil) {
            [self.downloadImage setImage:image];
        }
        else{
            NSLog(@"error - %@", [error localizedDescription]);
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)shareWithinApps:(id)sender {
    NSArray *itemsToShare = @[self.tvSerie.overview];
    
    // because not all TVSeries have homepage, when they dont have ill share the overview
    if(self.homepage != nil)
        itemsToShare = @[self.homepage];
    UIActivityViewController *uiacv = [ [UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil ];
    [self presentViewController:uiacv animated:YES completion:nil];
}


-(void)doSearchRequest:(NSNumber*)tv_id{
    
    NSURL *requestURL = [HttpRequestsUtility buildRequestURL:API_BASE_URL andPath:[NSString stringWithFormat:@"movie/%@",tv_id.stringValue] withQueryParams:@{@"api_key": API_KEY}];
    
    [HttpRequestsUtility executeGETRequest:requestURL withCompletion:^(id response, NSError *error) {
        //this completion handler code is executing in background
        if(error != nil) {
            NSLog(@"error - %@", [error localizedDescription]);
            
        }
        
        
        
        //parse the service response and transform into Model Objects
        NSDictionary *dict = (NSDictionary*)response;
        self.homepage = [dict objectForKey:@"homepage"];
        
        
        
        
        
    }];
    
}



@end
