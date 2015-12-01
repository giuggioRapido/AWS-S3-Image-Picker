//
//  UploadViewController.h
//  AmazonS3
//
//  Created by Chris on 9/8/15.
//  Copyright (c) 2015 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

@interface UploadViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *uploadCompleteLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectImageButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest;
@property (nonatomic) uint64_t filesize;
@property (nonatomic) uint64_t amountUploaded;

@end
