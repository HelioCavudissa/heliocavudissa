
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
#import "TVSerieCoreDataHelper.h"
#import "TVSerieTableViewCell.h"
#import "TVSerie.h"
#import "DetailTVSerieViewController.h"
#import "Reachability.h"

@interface TVSerieListViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lastTimeUpdate;

@property (strong, nonatomic) TVSerieCoreDataHelper *dbHelper;
@property (weak, nonatomic) IBOutlet UITableView *listView;
@property (nonatomic, strong) NSMutableArray *tvSeriesRepo;
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) NSNumber *numberPages;
@property (nonatomic,assign) int counter ;
@property (nonatomic,assign) Boolean isSearching ;
@property (nonatomic, strong) NSMutableArray  *searchResults;
@property (nonatomic, strong)  NSDateFormatter *dateFormatter;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchSerieBar;
@property (nonatomic,assign) Boolean isFirstRequest ;


@end

@implementation TVSerieListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dbHelper = [[TVSerieCoreDataHelper alloc] init];
    self.tvSeriesRepo = [ [NSMutableArray alloc] init];
    self.searchResults = [ [NSMutableArray alloc] init];
    self.listView.dataSource = self;
    self.listView.delegate = self;
    self.searchSerieBar.delegate = self;
    self.searchSerieBar.showsCancelButton =true;
    self.counter =1;
    self.isSearching=false;
    self.isFirstRequest = true;
    
    
    
    //  NSLocale *deviceLocale = [NSLocale currentLocale];
    
    ///  NSNumberFormatter *formater =[[NSNumberFormatter alloc] init];
    ///   formater.locale = deviceLocale;
    ///  NSString *heardertext = NSLocalizedString(@"Movie.List.Header.RefreshDate.Text update", nil);
    
    
    // setting footerView
    [self loadTVSeries];
    //Setting refreshControl
    [self refreshSettings];
    [self loadFromDBOrRequestFromAPI:1];
     self.isFirstRequest=false;
    
    
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    
    TVSerieTableViewCell *cell = (TVSerieTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"utilizador-right-detail-cell"];
    
    
    TVSerie *item =  (self.isSearching) ? [self.searchResults objectAtIndex:indexPath.row] : [self.tvSeriesRepo objectAtIndex:indexPath.row];
    
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
    return self.isSearching ? self.searchResults.count : self.tvSeriesRepo.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //obtenção do modelo dos utilizadores correspondente à linha seleccionada
    TVSerie *item = self.isSearching ? [self.searchResults objectAtIndex:indexPath.row]:[self.tvSeriesRepo objectAtIndex:indexPath.row];
    
    //Instanciação manual do ecrã seguinte no fluxo recorrendo ao carregamento do storyboard a partir do nome deste e o ViewController a partir do identificador atribuido no Interface Builder
    UIStoryboard *sbMain = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailTVSerieViewController *detail = (DetailTVSerieViewController*)[sbMain instantiateViewControllerWithIdentifier:@"serie-detail-view-controller"];
    
    //afectação das propriedades do ecrã antes de promover a sua apresentação
    detail.tvSerie = item;
    //navegação de forma programática para o ecrã seguinte no fluxo
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)loadTVSeries  {
    
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
  

    if([self networkConnection])
        [self doSearchRequest:[searchBar.text lowercaseString]];
    else
        for(TVSerie *tvSerie in self.tvSeriesRepo){
            NSString* title = [tvSerie.name lowercaseString];
            if([title containsString:[searchBar.text lowercaseString]]){
                [self.searchResults addObject:tvSerie];
            }
        }
    
    
    self.isSearching=true;
    
    [self.listView reloadData];
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.isSearching=false;
    [self.searchResults removeAllObjects];
    [self.listView reloadData];
    self.searchSerieBar.text = @"";
    
}

-(void)doRequest:(int)page{
    NSURL *requestURL = [HttpRequestsUtility buildRequestURL:API_BASE_URL andPath:@"tv/popular" withQueryParams:@{@"api_key": API_KEY, @"language": @"pt-PT", @"page": [NSString stringWithFormat:@"%d",page]}];
    
    __weak TVSerieListViewController *weakSelf = self;
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
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            [pref setObject:currentDate forKey:@"keyToLastTVSeriesUpdate"];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getLastUpadateTime];
            });
            
            //parse the service response and transform into Model Objects
            NSDictionary *dict = (NSDictionary*)response;
            NSLog(@"response - %@", dict);
            
            
            TVSerieResponse *responseParse = [[TVSerieResponse alloc] initWithDictionary:dict];
            self.numberPages = responseParse.total_pages;
            if(responseParse.page.integerValue == 1){
                
                [self.tvSeriesRepo removeAllObjects];
            }
            [self.tvSeriesRepo addObjectsFromArray: responseParse.results ];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listView reloadData];
            });
            //save retrieved model objects in coredata database via dbhelper instanfe
            //only the first time or for the next pages
            if(self.isFirstRequest || page>1)
                [weakSelf.dbHelper saveOrUpdateTVSerieList:responseParse.results];
            
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
    
    [self.dbHelper loadTVSeriesPage:page withSize:10 withCompletionHandler:^(NSMutableArray *results, NSError *error) {
        if(results.count) {
            NSLog(@"resultsCount - %lu", results.count);
            [self.tvSeriesRepo addObjectsFromArray:results];
            
            
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

-(void)getLastUpadateTime{
    NSUserDefaults *pref= [NSUserDefaults standardUserDefaults];
    NSString *currentDate = [pref stringForKey:@"keyToLastTVSeriesUpdate"];
    self.lastTimeUpdate.text =[NSString stringWithFormat:@"LastUpdate :%@", currentDate];
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


-(void)doSearchRequest:(NSString*)query{
    
    NSURL *requestURL = [HttpRequestsUtility buildRequestURL:API_BASE_URL andPath:@"search/tv" withQueryParams:@{@"api_key": API_KEY, @"language": @"pt-PT",@"query": query,@"page": [NSString stringWithFormat:@"%d",1]}];
    [HttpRequestsUtility executeGETRequest:requestURL withCompletion:^(id response, NSError *error) {
        //this completion handler code is executing in background
        if(error != nil) {
            NSLog(@"error - %@", [error localizedDescription]);

            [self displayToast];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getLastUpadateTime];
        });
        
        //parse the service response and transform into Model Objects
        NSDictionary *dict = (NSDictionary*)response;
        NSLog(@"response - %@", dict);
        
        
         TVSerieResponse  *responseParse = [[ TVSerieResponse  alloc] initWithDictionary:dict];
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




@end
