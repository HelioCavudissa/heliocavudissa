//
//  ViewController.m
//  FLAGProj
//
//  Created by Pedro Brito on 03/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "ViewController.h"

#import "Configs.h"
#import "HttpRequestsUtility.h"
#import "MoviesResponse.h"
#import "CoreDataHelper.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *downloadImage;
@property (strong, nonatomic) CoreDataHelper *dbHelper;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
