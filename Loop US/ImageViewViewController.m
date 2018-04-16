//
//  ImageViewViewController.m
//  Loop US
//
//  Created by Dnyaneshwar Shinde on 28/11/17.
//  Copyright © 2017 Dnyaneshwar Shinde. All rights reserved.
//

#import "ImageViewViewController.h"

@interface ImageViewViewController ()

@end

@implementation ImageViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    UIImage *image = [UIImage imageWithData:self.fileDatarecived];
    self.reivedImage.image = image ;
    NSLog(@"%@",self.fileDatarecived);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)DownloadButtonClickAction:(UIBarButtonItem *)sender {
          [self.fileDatarecived writeToFile:[NSString stringWithFormat:@"%@/Image.png", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]] atomically:YES];
    
     UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:self.fileDatarecived], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [self invokeAlertMethod:@"Successfully Sent" Body:@"Image shared successfully and saved in Cameraroll." Delegate:nil];
    }
}
- (void)invokeAlertMethod:(NSString *)strTitle Body:(NSString *)strBody Delegate:(id)delegate
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:strTitle
                                                                   message:strBody preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
