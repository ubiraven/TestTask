//
//  TETMainViewController.h
//  TestTask
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 ArtemyevSergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Requests.h"
#import "RespondsForRequest.h"
#import "CoreDataHelper.h"
#import "AFNetworking.h"
#import <UIAlertView+AFNetworking.h>
#import "TETCollectionViewCell.h"
#import "TETDetailedViewController.h"
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>

@interface TETMainViewController : UICollectionViewController <UISearchBarDelegate,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate>

@property (strong,nonatomic) UISearchBar *searchBar;
@property (strong,nonatomic) AFHTTPRequestOperationManager *requestOperationManager;
@property (strong,nonatomic) NSManagedObjectContext *moc;
@property (strong,nonatomic) SDImageCache *imageCacheManager;
@property (strong,nonatomic) NSArray *dataForCollectionView;
@property (strong,nonatomic) NSTimer *userResponseTimer;

- (IBAction)resignKeyboard:(id)sender;

@end
