//
//  DownloadViewController.m
//  AmazonS3
//
//  Created by Chris on 9/8/15.
//  Copyright (c) 2015 Prince Fungus. All rights reserved.
//

#import "DownloadViewController.h"

@interface DownloadViewController ()

@end

@implementation DownloadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.downloadRequests = [[NSMutableArray alloc]init];
    self.tableView.delegate = self;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.downloadRequests removeAllObjects];
    //[self.tableView reloadData];
    [self listFromBucket];
}

#pragma mark S3 methods
-(void)listFromBucket
{
    AWSS3 *s3 = [AWSS3 defaultS3];
    
    AWSS3ListObjectsRequest *listRequest = [[AWSS3ListObjectsRequest alloc] init];
    listRequest.bucket = @"BUCKET";
    listRequest.prefix = @"PREFIX";
    
    [[s3 listObjects:listRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"listObjects failed: [%@]", task.error);
        } else {
            AWSS3ListObjectsOutput *listObjectsOutput = task.result;
            for (AWSS3Object *s3Object in listObjectsOutput.contents)
            {
                
                NSString *imageName = [s3Object.key stringByReplacingOccurrencesOfString:@"pictures/" withString:@""];
                
                NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
                
                NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                
                
                AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                downloadRequest.bucket = @"BUCKET";
                downloadRequest.key = s3Object.key;
                downloadRequest.downloadingFileURL = downloadingFileURL;
                [self.downloadRequests addObject:downloadRequest];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        return nil;
    }];
}

-(void) downloadFromS3:(AWSS3TransferManagerDownloadRequest *)downloadRequest
{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager download:downloadRequest] continueWithBlock:^id(AWSTask *task) {
        if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]
            && task.error.code == AWSS3TransferManagerErrorPaused) {
            NSLog(@"Download paused.");
        } else if (task.error) {
            NSLog(@"Download failed: [%@]", task.error);
        } else {
            __weak DownloadViewController *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                DownloadViewController *strongSelf = weakSelf;
                
                NSUInteger index = [strongSelf.downloadRequests indexOfObject:downloadRequest];
                [strongSelf.downloadRequests replaceObjectAtIndex:index
                                                       withObject:downloadRequest.downloadingFileURL];
                
                
                
                // Following code causes crash
                //                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                //                                                            inSection:0];
                //
                
                //                [strongSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                NSLog(@"download successful");
                
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Download Successful"
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                }];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                
                
            });
        }
        return nil;
    }];
    
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.downloadRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if(!cell)
    {
        cell =
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSString *folderAndImageName = [NSString stringWithFormat:@"%@", [[self.downloadRequests objectAtIndex: indexPath.row]key]];
    
    NSString * imageName = [folderAndImageName stringByReplacingOccurrencesOfString:@"pictures/" withString:@""];
    
    cell.textLabel.text = imageName;
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AWSS3TransferManagerDownloadRequest *downloadRequest = [self.downloadRequests objectAtIndex:indexPath.row];
    [self downloadFromS3: downloadRequest];
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
