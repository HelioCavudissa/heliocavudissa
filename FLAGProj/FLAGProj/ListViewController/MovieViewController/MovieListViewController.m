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
#import "Reachability.h"



@interface MovieListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchMovieBar;
@property (weak, nonatomic) IBOutlet UILabel *lastTimeUpdate;
@property (weak, nonatomic) IBOutlet UIImageView *downloadImage;
@property (strong, nonatomic) CoreDataHelper *dbHelper;
@property (weak, nonatomic) IBOutlet UITableView *listView;
@property (nonatomic, strong) NSMutableArray *moviesRepo;
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) NSNumber *numberPages;
@property (nonatomic,assign) int counter ;
@property (nonatomic,assign) Boolean isSearching ;
@property (nonatomic,assign) Boolean isFirstRequest ;
@property (nonatomic, strong) NSMutableArray  *searchResults;
@property (nonatomic, strong)  NSDateFormatter *dateFormatter;
@property (nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MovieListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dbHelper = [[CoreDataHelper alloc] init];
    self.moviesRepo = [ [NSMutableArray alloc] init];
    self.searchResults = [ [NSMutableArray alloc] init];
    self.listView.dataSource = self;
    self.listView.delegate = self;
    self.searchMovieBar.delegate = self;
    self.searchMovieBar.showsCancelButton =true;
    self.counter =1;
    self.isSearching=false;
    self.isFirstRequest = true;
 
 

    // setting footerView
    [self loadMovies];
    //Setting refreshControl
    [self refreshSettings];
    [self loadFromDBOrRequestFromAPI:1];
    self.isFirstRequest=false;
    
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    
    MovieTableViewCell *cell = (MovieTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"utilizador-right-detail-cell"];
    
    
    Movie *item =  (self.isSearching) ? [self.searchResults objectAtIndex:indexPath.row] : [self.moviesRepo objectAtIndex:indexPath.row];
    
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
    return self.isSearching ? self.searchResults.count : self.moviesRepo.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //obtenção do modelo dos utilizadores correspondente à linha seleccionada
    Movie *item = self.isSearching ? [self.searchResults objectAtIndex:indexPath.row]:[self.moviesRepo objectAtIndex:indexPath.row];
    
    //Instanciação manual do ecrã seguinte no fluxo recorrendo ao carregamento do storyboard a partir do nome deste e o ViewController a partir do identificador atribuido no Interface Builder
    UIStoryboard *sbMain = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *detail = (DetailViewController*)[sbMain instantiateViewControllerWithIdentifier:@"movie-detail-view-controller"];
    
    //afectação das propriedades do ecrã antes de promover a sua apresentação
    detail.movie = item;
    //navegação de forma programática para o ecrã seguinte no fluxo
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)loadMovies  {
    
    if(!self.footerView){
    
        CGRect footerFrame = CGRectMake(0, 0, self.listView.bounds.size.width, 50);
        self.footerView = [[UIView alloc] initWithFrame:footerFrame];
        [self.footerView setBackgroundColor:[UIColor redColor]];
        [self.footerView setTintColor:[UIColor whiteColor]];
        
        UILabel *loadMore = [[UILabel alloc] initWithFrame: footerFrame];
        [loadMore setText:@"load movies"];
        [self.footerView addSubview:loadMore];
        UITapGestureRecognizer *footerTap = [[UITapGestureRecognizer alloc ] initWithTarget:self action:@selector(footerTaped)];
        footerTap.numberOfTapsRequired = 1;
        [self.footerView addGestureRecognizer:footerTap];
    }
    
    if(self.counter>0)
       self.listView.tableFooterView=self.footerView;
    else
    self.listView.tableFooterView=[[UIView alloc] init];
        
    
}


-(void)footerTaped{
    
       if(++self.counter < self.numberPages.integerValue){
              [self loadFromDBOrRequestFromAPI:self.counter];
        }
        else
              self.counter=0;
    }





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

/*    for(Movie *movie in self.moviesRepo){
        NSString* title = [movie.title lowercaseString];
        if([title containsString:[searchBar.text lowercaseString]]){
            [self.searchResults addObject:movie];
        }
    }*/
   if([self networkConnection])
       [self doSearchRequest:[searchBar.text lowercaseString]];
   else
       [self searchInDB:searchBar.text];
        
    self.isSearching=true;
    
    [self.listView reloadData];
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.isSearching=false;
    [self.searchResults removeAllObjects];
    [self.listView reloadData];
    self.searchMovieBar.text = @"";
    
}

-(void)doRequest:(int)page{
    
    NSURL *requestURL = [HttpRequestsUtility buildRequestURL:API_BASE_URL andPath:@"movie/now_playing" withQueryParams:@{@"api_key": API_KEY, @"language": @"pt-PT", @"page": [NSString stringWithFormat:@"%d",page]}];
    
    __weak MovieListViewController *weakSelf = self;
    [HttpRequestsUtility executeGETRequest:requestURL withCompletion:^(id response, NSError *error) {
        //this completion handler code is executing in background
        if(error != nil) {
            NSLog(@"error - %@", [error localizedDescription]);
            [self loadFromDB:page];
            [self displayToast];
        }
        else {
             self.dateFormatter = [[NSDateFormatter alloc] init];
             [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
             NSString *currentDate = [self.dateFormatter stringFromDate:[NSDate date]];
             NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
             [prefs setObject:currentDate forKey:@"keyToLastUpdate"];
            
           
            dispatch_async(dispatch_get_main_queue(), ^{
                  [self getLastUpadateTime];
            });
            
            //parse the service response and transform into Model Objects
            NSDictionary *dict = (NSDictionary*)response;
            NSLog(@"response - %@", dict);
            
        
            MoviesResponse *responseParse = [[MoviesResponse alloc] initWithDictionary:dict];
            self.numberPages = responseParse.total_pages;
            if(responseParse.page.integerValue == 1){
                
                [self.moviesRepo removeAllObjects];
            }
            [self.moviesRepo addObjectsFromArray: responseParse.results ];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listView reloadData];
            });
            //save retrieved model objects in coredata database via dbhelper instanfe
            //only the first time or for the next pages
            if(self.isFirstRequest || page>1)
                [weakSelf.dbHelper saveOrUpdateMovieList:responseParse.results];
           
        }
    }];
    
}

-(void)doSearchRequest:(NSString*)query{
    
    NSURL *requestURL = [HttpRequestsUtility buildRequestURL:API_BASE_URL andPath:@"search/movie" withQueryParams:@{@"api_key": API_KEY, @"language": @"pt-PT",@"query": query,@"page": [NSString stringWithFormat:@"%d",1]}];
    
    [HttpRequestsUtility executeGETRequest:requestURL withCompletion:^(id response, NSError *error) {
        //this completion handler code is executing in background
        if(error != nil) {
            NSLog(@"error - %@", [error localizedDescription]);
            [self searchInDB:query];
            [self displayToast];
        }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self getLastUpadateTime];
            });
            
            //parse the service response and transform into Model Objects
            NSDictionary *dict = (NSDictionary*)response;
            NSLog(@"response - %@", dict);
            
            
            MoviesResponse *responseParse = [[MoviesResponse alloc] initWithDictionary:dict];
            self.numberPages = responseParse.total_pages;
            if(responseParse.page.integerValue == 1){
                
            [self.searchResults removeAllObjects];
            }
            [self.searchResults addObjectsFromArray: responseParse.results ];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listView reloadData];
            });
           
            
    }];
    
}


- (void)refreshTable {
    
    [self doRequest:1];
    [self.refreshControl endRefreshing];
    [self.listView reloadData];
}

- (void)refreshSettings{
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.listView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    //Setting the tint Color of the Activity Animation
    self.refreshControl.tintColor = [UIColor blackColor];
}

- (void)displayToast{
    NSString *message = @"Please connect to internet...";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message  preferredStyle:UIAlertControllerStyleActionSheet];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    int duration = 10; // duration in seconds
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [alert dismissViewControllerAnimated:YES completion:nil];
        
    });
}

- (BOOL)networkConnection {
    return [[Reachability reachabilityWithHostName:@"www.google.com"] currentReachabilityStatus];
}

-(void)loadFromDBOrRequestFromAPI:(int)page{

    if ([self networkConnection] == NotReachable) {
        
        [self loadFromDB:page];
        
    } else {
        //First request , where  1 is the page's number
        [self doRequest:page];
        
        
    }

}

-(void)loadFromDB:(int)page{
    
    [self.dbHelper loadMoviesPage:page withSize:10 withCompletionHandler:^(NSMutableArray *results, NSError *error) {
        if(results.count) {
            NSLog(@"resultsCount - %lu", results.count);
            [self.moviesRepo addObjectsFromArray:results];
   
        }
        if(results.count==0)
            [self displayToast];
        
        if(error) {
            NSLog(@"error - %@", [error localizedDescription]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
                [self getLastUpadateTime];
            });
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listView reloadData];
            });
            
    }];
    
}

-(void)searchInDB:(NSString*)query{
    
    [self.dbHelper loadMoviesPage:1 withSize:10 withCompletionHandler:^(NSMutableArray *results, NSError *error) {
        if(results.count) {
            NSLog(@"resultsCount - %lu", results.count);
        
            for(Movie *movie in results){
                NSString* title = [movie.title lowercaseString];
                if([title containsString:[query lowercaseString]]){
                    [self.searchResults addObject:movie];
                }
            }
            self.isSearching=true;
            
            
        }
        
        if(error) {
            NSLog(@"error - %@", [error localizedDescription]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getLastUpadateTime];
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listView reloadData];
        });
        
    }];
    
}

-(void)getLastUpadateTime{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *currentDate = [prefs stringForKey:@"keyToLastUpdate"];
    self.lastTimeUpdate.text =[NSString stringWithFormat:@"LastUpdate :%@", currentDate];
}

@end
