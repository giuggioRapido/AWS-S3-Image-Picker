//
//  DownloadViewController.h
//  AmazonS3
//
//  Created by Chris on 9/8/15.
//  Copyright (c) 2015 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

@interface DownloadViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *downloadRequests;

@end
