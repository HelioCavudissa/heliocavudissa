//
//  TVSerieListViewController.m
//  FLAGProj
//
//  Created by Hélio Cavudissa on 15/03/18.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "TVSerieListViewController.h"
#import "Configs.h"
#import "HttpRequestsUtility.h"
#import "TVSerieResponse.h"
#import "CoreDataHelper.h"
#import "TVSerieTableViewCell.h"
#import "TVSerie.h"
#import "DetailTVSerieViewController.h"

@interface TVSerieListViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (strong, nonatomic) CoreDataHelper *dbHelper;
@property (weak, nonatomic) IBOutlet UITableView *listView;
@property (nonatomic, strong) NSMutableArray *moviesRepo;
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) NSNumber *numberPages;
@property (nonatomic,assign) int counter ;
@property (nonatomic,assign) Boolean isSearching ;
@property (nonatomic, strong) NSMutableArray  *searchResults;
@property (nonatomic, strong)  NSDateFormatter *dateFormatter;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchMovieBar;

@end

@implementation TVSerieListViewController

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
    
    
    
    
    
    
    
    //  NSLocale *deviceLocale = [NSLocale currentLocale];
    
    ///  NSNumberFormatter *formater =[[NSNumberFormatter alloc] init];
    ///   formater.locale = deviceLocale;
    ///  NSString *heardertext = NSLocalizedString(@"Movie.List.Header.RefreshDate.Text update", nil);
    
    
    // setting footerView
    [self loadMovies];
    //Setting refreshControl
    [self refreshSettings];
    //First request , where  1 is the page's number
    [self doRequest:1];
    
    
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
    
    
    TVSerieTableViewCell *cell = (TVSerieTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"utilizador-right-detail-cell"];
    
    
    TVSerie *item =  (self.isSearching) ? [self.searchResults objectAtIndex:indexPath.row] : [self.moviesRepo objectAtIndex:indexPath.row];
    
    [cell setCellValues:item];
    
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
    TVSerie *item = self.isSearching ? [self.searchResults objectAtIndex:indexPath.row]:[self.moviesRepo objectAtIndex:indexPath.row];
    
    //Instanciação manual do ecrã seguinte no fluxo recorrendo ao carregamento do storyboard a partir do nome deste e o ViewController a partir do identificador atribuido no Interface Builder
    UIStoryboard *sbMain = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailTVSerieViewController *detail = (DetailTVSerieViewController*)[sbMain instantiateViewControllerWithIdentifier:@"serie-detail-view-controller"];
    
    //afectação das propriedades do ecrã antes de promover a sua apresentação
    detail.tvSerie = item;
    //navegação de forma programática para o ecrã seguinte no fluxo
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)loadMovies  {
    
    CGRect footerFrame = CGRectMake(0, 0, self.listView.bounds.size.width, 50);
    self.footerView = [[UIView alloc] initWithFrame:footerFrame];
    [self.footerView setBackgroundColor:[UIColor redColor]];
    [self.footerView setTintColor:[UIColor whiteColor]];
    
    UILabel *loadMore = [[UILabel alloc] initWithFrame: footerFrame];
    [loadMore setText:@"load tvSeries"];
    [self.footerView addSubview:loadMore];
    UITapGestureRecognizer *footerTap = [[UITapGestureRecognizer alloc ] initWithTarget:self action:@selector(footerTaped)];
    footerTap.numberOfTapsRequired = 1;
    [self.footerView addGestureRecognizer:footerTap];
    
    if(self.counter>0)
        self.listView.tableFooterView=self.footerView;
    else
        self.listView.tableFooterView=[[UIView alloc] init];
    
    
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 1. The view for the header
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
    
    // 2. Set a custom background color and a border
    headerView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
    headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
    headerView.layer.borderWidth = 1.0;
    
    // 3. Add a label
    UILabel* headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(5, 2, tableView.frame.size.width - 5, 18);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
    
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *currentDate = [self.dateFormatter stringFromDate:[NSDate date]];
    
    headerLabel.text =[NSString stringWithFormat:@"LastUpdate :%@", currentDate];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    
    // 4. Add the label to the header view
    [headerView addSubview:headerLabel];
    
    // 5. Finally return
    return headerView;
}
-(void)footerTaped{
    
    if(++self.counter < self.numberPages.integerValue){
        [self doRequest:self.counter];
    }
    else
        self.counter=0;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    for(Movie *movie in self.moviesRepo){
        NSString* title = [movie.title lowercaseString];
        if([title containsString:[searchBar.text lowercaseString]]){
            [self.searchResults addObject:movie];
        }
    }
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
    
    NSURL *requestURL = [HttpRequestsUtility buildRequestURL:API_BASE_URL andPath:@"tv/popular" withQueryParams:@{@"api_key": API_KEY, @"language": @"pt-PT", @"page": [NSString stringWithFormat:@"%d",page]}];
    
    __weak TVSerieListViewController *weakSelf = self;
    [HttpRequestsUtility executeGETRequest:requestURL withCompletion:^(id response, NSError *error) {
        //this completion handler code is executing in background
        if(error != nil) {
            NSLog(@"error - %@", [error localizedDescription]);
        }
        else {
            self.dateFormatter = [[NSDateFormatter alloc] init];
            //parse the service response and transform into Model Objects
            NSDictionary *dict = (NSDictionary*)response;
            NSLog(@"response - %@", dict);
            
            TVSerieResponse *responseParse = [[TVSerieResponse alloc] initWithDictionary:dict];
            [self.moviesRepo addObjectsFromArray: responseParse.results ];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listView reloadData];
            });
            //save retrieved model objects in coredata database via dbhelper instanfe
            [weakSelf.dbHelper saveOrUpdateMovieList:responseParse.results];
        }
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

@end
