//
//  TETMainViewController.m
//  TestTask
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 ArtemyevSergey. All rights reserved.
//

#import "TETMainViewController.h"
#define numberOfElementsInRow 2  //кол-во элементов в ряду
#define collectionViewInsets 10  //размер отступов
#define reuseIdentifier @"Cell"

@interface TETMainViewController ()

@end

BOOL loadingInProgress;           //флаг о наличии процесса загрузки
NSObject *observatorForDeleting;  //объект, подписанный на уведомление из центра
static int pictureSize;           //размер картинок для загрузки

@implementation TETMainViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //инициализация основных объектов для приложения
    _moc = [(AppDelegate*)[[UIApplication sharedApplication]delegate]managedObjectContext];
    _requestOperationManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:@"http://maps.googleapis.com/maps/api/geocode/json"]];
    _imageCacheManager = [SDImageCache sharedImageCache];
    _searchBar = [UISearchBar new];
    _dataForCollectionView = [NSArray new];
    
    //запуск процесса мониторинга наличия доступа к сервису Google
    NSOperationQueue *managerQueue = _requestOperationManager.operationQueue;
    [_requestOperationManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [managerQueue setSuspended:NO];
                //NSLog(@"host is reachable");
                [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:@"Google service is reachable" object:nil]];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [managerQueue setSuspended:NO];
                //NSLog(@"host is unreachable");
                [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:@"Google service is unreachable" object:nil]];
                break;
        }
    }];
    [_requestOperationManager.reachabilityManager startMonitoring];
    
    //при наличии доступа к сети, удаляются элементы из кеша, которые хранятся более 30 дней, при отсутствии сети, выдается сообщение.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(unreachabilityAlertView) name:@"Google service is unreachable" object:nil];
    observatorForDeleting = [[NSNotificationCenter defaultCenter]addObserverForName:@"Google service is reachable" object:nil queue:[NSOperationQueue new] usingBlock:^(NSNotification *note) {
        [self performSelector:@selector(deleteExpiredDataFromCache)];
    }];
    
    //настройка максимальной длительности хранения картинок в кэше
    _imageCacheManager.maxCacheAge = 60 * 60 * 24 * 30;//(30 суток)
    
    //настройка поисковой строки
    self.navigationItem.titleView = _searchBar;
    _searchBar.delegate =self;
    _searchBar.placeholder = @"Текст запроса";
    
    //расчет размера картинок для загрузки, в зависимости от размера экрана
    CGRect screenSize = [[UIScreen mainScreen]bounds];
    pictureSize = screenSize.size.width;
    if (screenSize.size.height < pictureSize) {
        pictureSize = screenSize.size.height;
    }
    if (pictureSize < 500) {
        pictureSize = 500;
    }
    //NSLog(@"%i",pictureSize);
}
- (void)unreachabilityAlertView {
    UIAlertView *unreachableAlert = [[UIAlertView alloc]initWithTitle:@"Сервис Google недоступен"  message:@"Проблема с сетью" delegate:self cancelButtonTitle:@"Продолжить в оффлайн режиме" otherButtonTitles:nil];
    [unreachableAlert show];
}

//удаление из кэша данных, которые были получены более месяца назад
- (void)deleteExpiredDataFromCache {
    //NSLog(@"deleting");
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-60 * 60 *24 * 30];
    //NSLog(@"%@",date);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateOfRequest < %@",date];
    NSArray *requestsArray = [CoreDataHelper fetchEntitiesWith:@"Requests" in:_moc with:predicate];
    //NSLog(@"%@",requestsArray);
    for (Requests *expiredRequest in requestsArray) {
        [_moc deleteObject:expiredRequest];
        //NSLog(@"has been deleted");
    }
    [_moc save:nil];
    [_imageCacheManager cleanDisk];
    [[NSNotificationCenter defaultCenter]removeObserver:observatorForDeleting];
}

//методы для расчета размера элементов CollectionView (кол-во элементов в ряду и размеры отступов можно подогнать, изменив константы)
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = (self.view.frame.size.width - collectionViewInsets * (numberOfElementsInRow + 1)) / numberOfElementsInRow;
    float height = width * 4/3;
    CGSize cellSize = CGSizeMake(width, height);
    return cellSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return collectionViewInsets;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return collectionViewInsets;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(collectionViewInsets, collectionViewInsets, collectionViewInsets, collectionViewInsets);
    return edgeInsets;
}

//методы для обработки ротации устройства (закомментить, если при повороте не требуется подгонять размеры элементов)
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView.collectionViewLayout invalidateLayout];
    //NSLog(@"version 8.0");
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.collectionView.collectionViewLayout invalidateLayout];
    //NSLog(@"version 7.0");
}


//searchBar методы
//при вводе текста, запускается таймер, который через 2 секунды запустит процесс загрузки данных, если пользователь не ввел еще значение, тогда таймер обнуляется.
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //NSLog(@"%@",searchText);
    loadingInProgress = NO;
    [_userResponseTimer invalidate];
    if ([searchText isEqualToString:@""]) {
    }else{
        _userResponseTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timeFireMethod:) userInfo:nil repeats:NO];
    }
}
//если загрузка уже началась по таймеру, кнопка Search не будет запускать повторно тот же запрос.
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //NSLog(@"searchButton");
    if (loadingInProgress) {
        //NSLog(@"loading is already in progress");
       [_searchBar resignFirstResponder];
    }else{
       [_userResponseTimer invalidate];
       [self checkTheCacheFor:searchBar.text];
       [_searchBar resignFirstResponder];
    }
}
//убрать клавиатуру с экрана при нажатии на свободное место, связано с UIImageView.
- (IBAction)resignKeyboard:(id)sender {
    NSLog(@"!");
    [_searchBar resignFirstResponder];
}

//метод таймера
- (void)timeFireMethod:(NSTimer*)timer {
    [self checkTheCacheFor:_searchBar.text];
}
//проверка CoreData на наличие в нем данных для запроса
- (void)checkTheCacheFor:(NSString*)address {
    loadingInProgress = YES;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"requestParameters like %@",address];
    Requests *request;
    if ([CoreDataHelper fetchEntitiesWith:@"Requests" in:_moc with:predicate].count > 0) {
        request = [[CoreDataHelper fetchEntitiesWith:@"Requests" in:_moc with:predicate]objectAtIndex:0];
    }
    if (request) {
        //NSLog(@"From Database");
        [self loadDataToCollectionViewWith:request];
    }else{
        //NSLog(@"From Network");
        [self makeRequestToGoogleMapsWithAddress:address];
    }
}
//запрос к Google, и заполнение списков в CoreData из полученных данных
- (void)makeRequestToGoogleMapsWithAddress:(NSString*)address {
    NSDictionary *parameters = @{@"address":address};
    [_requestOperationManager GET:@"http://maps.googleapis.com/maps/api/geocode/json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        //NSLog(@"class: %@",[responseObject class]);
        
        Requests *request = [CoreDataHelper insertManagedObjectWith:@"Requests" in:_moc];
        request.requestParameters = address;
        request.dateOfRequest = [NSDate date];
        
        NSMutableSet *respondsSet = [NSMutableSet new];
        int i = 0;
        for (NSDictionary *responseDictionary in [responseObject objectForKey:@"results"]) {
            RespondsForRequest *response = [CoreDataHelper insertManagedObjectWith:@"RespondsForRequest" in:_moc];
            response.responseNumber = [NSNumber numberWithInt:i];
            response.formattedAddress = [responseDictionary objectForKey:@"formatted_address"];
            response.centerLatitude = [[[responseDictionary objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"];
            response.centerLongitude = [[[responseDictionary objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"];
            response.northEastLatitude = [[[[responseDictionary objectForKey:@"geometry"]objectForKey:@"viewport"]objectForKey:@"northeast"] objectForKey:@"lat"];
            response.northEastLongitude = [[[[responseDictionary objectForKey:@"geometry"]objectForKey:@"viewport"]objectForKey:@"northeast"]objectForKey:@"lng"];
            response.southWestLatitude = [[[[responseDictionary objectForKey:@"geometry"]objectForKey:@"viewport"]objectForKey:@"southwest"]objectForKey:@"lat"];
            response.southWestLongitude = [[[[responseDictionary objectForKey:@"geometry"]objectForKey:@"viewport"]objectForKey:@"southwest"]objectForKey:@"lng"];
            response.imageURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&size=%ix%i&visible=%f,%f&visible=%f,%f",
                                                [response.centerLatitude doubleValue],
                                                [response.centerLongitude doubleValue],
                                                pictureSize,
                                                pictureSize,
                                                [response.northEastLatitude doubleValue],
                                                [response.northEastLongitude doubleValue],
                                                [response.southWestLatitude doubleValue],
                                                [response.southWestLongitude doubleValue]];
            response.request = request;
            [respondsSet addObject:response];
            i++;
        }
        request.responds = respondsSet;
        
        [_moc save:nil];
        [self loadDataToCollectionViewWith:request];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Failure");
        UIAlertView *failure = [[UIAlertView alloc]initWithTitle:@"Возникла ошибка при запросе" message:@"Возможна проблема с сетью" delegate:self cancelButtonTitle:@"Продолжить" otherButtonTitles:nil];
        [failure show];
    }];
}
//загрузка данных в массив для CollectionView
- (void)loadDataToCollectionViewWith:(Requests*)request {
    if (request.responds.count == 0) {
        //NSLog(@"Results 0");
        UIAlertView *noResultsFound = [[UIAlertView alloc]initWithTitle:@"Запрос не дал результатов" message:@"Попробуйте изменить данные для запроса" delegate:self cancelButtonTitle:@"Продолжить" otherButtonTitles:nil];
        [noResultsFound show];
    }else{
        _dataForCollectionView = [request.responds allObjects];
        _dataForCollectionView = [_dataForCollectionView sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
           if ([[obj1 responseNumber]intValue] > [[obj2 responseNumber]intValue]) {
               return (NSComparisonResult)NSOrderedDescending;
           }
           if ([[obj1 responseNumber]intValue] < [[obj2 responseNumber]intValue]) {
               return (NSComparisonResult)NSOrderedAscending;
           }
           return (NSComparisonResult)NSOrderedSame;
    }];
       //NSLog(@"%@",_dataForCollectionView);
       [self.collectionView reloadData];
    }
    loadingInProgress = NO;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataForCollectionView.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TETCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.addressLabel.text = [[_dataForCollectionView objectAtIndex:indexPath.row]formattedAddress];
    cell.addressLabel.adjustsFontSizeToFitWidth = YES;

    NSURL *imageURL = [NSURL URLWithString:[[_dataForCollectionView objectAtIndex:indexPath.row]imageURL]];
    //NSLog(@"%@",imageURL);
    
    //загрузка картинок из кэша или сети
    [cell.mapImage sd_setImageWithPreviousCachedImageWithURL:imageURL andPlaceholderImage:[UIImage imageNamed:@"infoButton.jpg"] options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //NSLog(@"%ld,%ld",(long)receivedSize,(long)expectedSize);
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //NSLog(@"%@",imageURL);
        //NSLog(@"%li",cacheType);
    }];
    
    return cell;
}

#pragma mark - Navigation
// при переходе на экран карты AppleMaps, контроллеру передается объект, содержащий данные ответа от сервиса Google
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Details"]) {
        TETCollectionViewCell *cell = (TETCollectionViewCell*)sender;
        NSInteger index = [[self.collectionView indexPathForCell:cell]row];
        TETDetailedViewController *newController = [segue destinationViewController];
        newController.placeDescription = [_dataForCollectionView objectAtIndex:index];
    }
}

#pragma mark <UICollectionViewDelegate>

// Uncomment this method to specify if the specified item should be highlighted during tracking
//При нажатии на элемент, он подсвечивается, через некоторе время возвращает свой вид
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    TETCollectionViewCell *cell = (TETCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.mapImage.alpha = 0.2f;
	return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    TETCollectionViewCell *cell = (TETCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [self performSelector:@selector(changeMapImageTransparencyToFull:) withObject:cell afterDelay:3.0f];
}
- (void)changeMapImageTransparencyToFull:(TETCollectionViewCell*)cell {
    cell.mapImage.alpha = 1.0f;
}
/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/
/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
