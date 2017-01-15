//
//  TETDetailedViewController.h
//  TestTask
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 ArtemyevSergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RespondsForRequest.h"

@interface TETDetailedViewController : UIViewController

@property (strong,nonatomic) RespondsForRequest *placeDescription; //объект с описанием места
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
