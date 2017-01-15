//
//  TETDetailedViewController.m
//  TestTask
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 ArtemyevSergey. All rights reserved.
//

#import "TETDetailedViewController.h"

@interface TETDetailedViewController ()

@end

@implementation TETDetailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSLog(@"%@",_placeDescription);
    
    //формирование отметки на карте
    CLLocationCoordinate2D placeCoordinates;
    placeCoordinates.latitude = [_placeDescription.centerLatitude doubleValue];
    placeCoordinates.longitude = [_placeDescription.centerLongitude doubleValue];
    MKPointAnnotation *PlacePoint = [MKPointAnnotation new];
    PlacePoint.coordinate = placeCoordinates;
    PlacePoint.title = @"Address";
    PlacePoint.subtitle = _placeDescription.formattedAddress;
    
    //настройка вида карты
    MKCoordinateRegion selectedRegion;
    selectedRegion.center = placeCoordinates;
    selectedRegion.span = MKCoordinateSpanMake(
                                  [_placeDescription.northEastLatitude doubleValue] - [_placeDescription.southWestLatitude doubleValue],[_placeDescription.northEastLongitude doubleValue] - [_placeDescription.southWestLongitude doubleValue]);
    [_mapView addAnnotation:PlacePoint];
    [_mapView setRegion:selectedRegion animated:YES];
    
    // Do any additional setup after loading the view.
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

@end
