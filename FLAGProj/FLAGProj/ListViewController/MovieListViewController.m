//
//  MovieListViewController.m
//  FLAGProj
//
//  Created by Admin on 08/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "MovieListViewController.h"

#import "Configs.h"
#import "HttpRequestsUtility.h"
#import "MoviesResponse.h"
#import "CoreDataHelper.h"
#import "MovieTableViewCell.h"
#import "Movie.h"
#import "DetailViewController.h"

@interface MovieListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *downloadImage;
@property (strong, nonatomic) CoreDataHelper *dbHelper;
@property (weak, nonatomic) IBOutlet UITableView *listView;
@property (nonatomic, strong) NSMutableArray *moviesRepo;
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic,strong) NSNumber *numberPages;
@property (nonatomic,assign) int counter ;
@end

@implementation MovieListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dbHelper = [[CoreDataHelper alloc] init];
    self.moviesRepo = [ [NSMutableArray alloc] init];
    self.listView.dataSource = self;
    self.listView.delegate = self;
    self.counter =1;
    
    [self loadMovies];
    
    //create a request for movies and call the webservice for a response
    NSURL *requestURL = [HttpRequestsUtility buildRequestURL:API_BASE_URL andPath:@"movie/now_playing" withQueryParams:@{@"api_key": API_KEY, @"language": @"pt-PT", @"page": @"1"}];
    
    __weak MovieListViewController *weakSelf = self;
    [HttpRequestsUtility executeGETRequest:requestURL withCompletion:^(id response, NSError *error) {
        //this completion handler code is executing in background
        if(error != nil) {
            NSLog(@"error - %@", [error localizedDescription]);
        }
        else {
            //parse the service response and transform into Model Objects
            NSDictionary *dict = (NSDictionary*)response;
            NSLog(@"response - %@", dict);
            
            MoviesResponse *responseParse = [[MoviesResponse alloc] initWithDictionary:dict];
            [self.moviesRepo addObjectsFromArray: responseParse.results ];
            self.numberPages = responseParse.total_pages;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listView reloadData];
            });
            //save retrieved model objects in coredata database via dbhelper instanfe
            [weakSelf.dbHelper saveOrUpdateMovieList:responseParse.results];
        }
    }];
    
    
    //create an image URL to download
    NSURL *imgRequestURL = [HttpRequestsUtility buildRequestURL:@"http://upload.wikimedia.org/wikipedia/commons/7/7f/Williams_River-27527.jpg" andPath:nil withQueryParams:nil];
    
    //execute download image and set UI image view resource in completion handler, useful for example when you need to work the image before applying it to the UIImageView
    [HttpRequestsUtility executeDownloadImage:imgRequestURL withCompletion:^(UIImage *image, NSError *error) {
        //this completion handler code is executing in foreground main thread
        if(error == nil) {
            weakSelf.downloadImage.image = image;
        }
    }];
    
    //execute download image and set UI image view resource in imageview passed by parameter; receive errors in failure block if an error occurs -> this is useful for example in lists, download images asynchronously
    [HttpRequestsUtility executeDownloadImage:imgRequestURL intoImageView:self.downloadImage withErrorHandler:^(NSError *error) {
        NSLog(@"Oh oh, something went wrong - %@", [error localizedDescription]);
    }];
    
    
    //load Movie Objects from core data, with pagination, executing all data fetch in background and delivering the results in foreground main thread
    [self.dbHelper loadMoviesPage:1 withSize:10 withCompletionHandler:^(NSMutableArray *results, NSError *error) {
        if(results.count) {
            NSLog(@"resultsCount - %lu", results.count);
        }
        
        if(error) {
            NSLog(@"error - %@", [error localizedDescription]);
        }
    }];
    
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    
    MovieTableViewCell *cell = (MovieTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"utilizador-right-detail-cell"];
    Movie *item = [self.moviesRepo objectAtIndex:indexPath.row];
    
    [cell setCellValues:item.title andreleaseDate:item.release_date andVoteAvg:item.vote_average.stringValue];
    
    //create an image URL to download
    NSURL *imgRequestURL = [HttpRequestsUtility buildRequestURL:@"https://image.tmdb.org/t/p/w500/" andPath:item.backdrop_path withQueryParams:nil];

    
    //execute download image and set UI image view resource in imageview passed by parameter; receive errors in failure block if an error occurs -> this is useful for example in lists, download images asynchronously
    [HttpRequestsUtility executeDownloadImage:imgRequestURL intoImageView:cell.imageLabel withErrorHandler:^(NSError *error) {
        NSLog(@"Oh oh, something went wrong - %@", [error localizedDescription]);
    }];
    
    //retorno do objecto já criado e afectado com o modelo
    return cell;
}



- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //retorno da contagem do número de linhas
    return self.moviesRepo.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //obtenção do modelo dos utilizadores correspondente à linha seleccionada
    Movie *item = [self.moviesRepo objectAtIndex:indexPath.row];
    
    //Instanciação manual do ecrã seguinte no fluxo recorrendo ao carregamento do storyboard a partir do nome deste e o ViewController a partir do identificador atribuido no Interface Builder
    UIStoryboard *sbMain = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *detail = (DetailViewController*)[sbMain instantiateViewControllerWithIdentifier:@"movie-detail-view-controller"];
    
    //afectação das propriedades do ecrã antes de promover a sua apresentação
    detail.movie = item;
    //navegação de forma programática para o ecrã seguinte no fluxo
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)loadMovies  {
    
    CGRect footerFrame = CGRectMake(0, 0, self.listView.bounds.size.width, 50);
    self.footerView = [[UIView alloc] initWithFrame:footerFrame];
    [self.footerView setBackgroundColor:[UIColor blackColor]];
    [self.footerView setTintColor:[UIColor whiteColor]];
    
    UILabel *loadMore = [[UILabel alloc] initWithFrame: footerFrame];
    [loadMore setText:@"load"];
    [self.footerView addSubview:loadMore];
    UITapGestureRecognizer *footerTap = [[UITapGestureRecognizer alloc ] initWithTarget:self action:@selector(footerView)];
    footerTap.numberOfTapsRequired = 1;
    [self.footerView addGestureRecognizer:footerTap];
    
    if(self.counter>0)
       self.listView.tableFooterView=self.footerView;
    else
    self.listView.tableFooterView=[[UIView alloc] init];
        
    
}

-(void)footerTaped{
    
  
    
    if(++self.counter < self.numberPages.integerValue){
            NSURL *requestURL = [HttpRequestsUtility buildRequestURL:API_BASE_URL andPath:@"movie/now_playing" withQueryParams:@{@"api_key": API_KEY, @"language": @"pt-PT", @"page":[ NSString stringWithFormat: ßself.counter ]}];
        
            __weak MovieListViewController *weakSelf = self;
            [HttpRequestsUtility executeGETRequest:requestURL withCompletion:^(id response, NSError *error) {
                //this completion handler code is executing in background
                if(error != nil) {
                    NSLog(@"error - %@", [error localizedDescription]);
                }
                else {
                    //parse the service response and transform into Model Objects
                    NSDictionary *dict = (NSDictionary*)response;
                    NSLog(@"response - %@", dict);
                    
                    MoviesResponse *responseParse = [[MoviesResponse alloc] initWithDictionary:dict];
                    [self.moviesRepo addObjectsFromArray: responseParse.results ];
                 
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.listView reloadData];
                    });
                    //save retrieved model objects in coredata database via dbhelper instanfe
                    [weakSelf.dbHelper saveOrUpdateMovieList:responseParse.results];
                }
            }];
        
            }
    else self.counter=0;
    
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
