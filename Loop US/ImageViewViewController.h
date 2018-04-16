//
//  ImageViewViewController.h
//  Loop US
//
//  Created by Dnyaneshwar Shinde on 28/11/17.
//  Copyright © 2017 Dnyaneshwar Shinde. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewViewController : UIViewController
- (IBAction)DownloadButtonClickAction:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *reivedImage;
@property(nonatomic,strong) NSMutableData *fileDatarecived;

@end
