//
//  UploadViewController.m
//  AmazonS3
//
//  Created by Chris on 9/8/15.
//  Copyright (c) 2015 Prince Fungus. All rights reserved.
//

#import "UploadViewController.h"

@interface UploadViewController ()

@end

@implementation UploadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set tab bar item images
    self.tabBarItem.image = [UIImage imageNamed:@"UploadIcon"];
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    item1.image = [UIImage imageNamed:@"DownloadIcon"];
    
    self.uploadCompleteLabel.hidden = YES;
    
    self.progressView.hidden = YES;
}

- (IBAction)pressSelectImageButton:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (IBAction)pressUploadButton:(id)sender
{
    self.progressView.hidden = NO;
    [self uploadToS3];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

-(void) uploadToS3
{
    UIImage *image = self.selectedImageView.image;
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"image.png"];
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:path atomically:YES];
    
    NSURL *url = [[NSURL alloc]initFileURLWithPath:path];
    
    self.uploadRequest = [[AWSS3TransferManagerUploadRequest alloc] init];
    self.uploadRequest.bucket = @"BUCKETNAME";
    
    int imageNumber = arc4random_uniform(100000);
    self.uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    self.uploadRequest.key = [NSString stringWithFormat: @"pictures/image%i.png", imageNumber];
    self.uploadRequest.contentType = [NSString stringWithFormat: @"image%i/png", imageNumber];
    self.uploadRequest.body = url;
    
    
    __weak UploadViewController *weakSelf = self;
    
    self.uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.amountUploaded = totalBytesSent;
            weakSelf.filesize = totalBytesExpectedToSend;
            [weakSelf update];
            if (totalBytesSent == totalBytesExpectedToSend)
            {
                weakSelf.progressView.hidden = YES;
                weakSelf.uploadCompleteLabel.hidden = NO;
            }
        });
    };
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[transferManager upload:self.uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task)
     {
         if (task.error) {
             NSLog(@"%@", task.error);
         } else {
             NSLog(@"IMAGEURL");
         }
         
         return nil;
     }];
}

-(void) update
{
    NSLog(@"Uploading:%.0f%%", ((float)self.amountUploaded/ (float)self.filesize * 100));
    
    self.progressView.progress = ((float)self.amountUploaded/ (float)self.filesize);
    self.selectedImageView.alpha = self.progressView.progress;
}


#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.selectedImageView.image = chosenImage;
    self.selectedImageView.alpha = 1.0;
    
    self.uploadButton.enabled = YES;
    
    self.uploadCompleteLabel.hidden = YES;
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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
