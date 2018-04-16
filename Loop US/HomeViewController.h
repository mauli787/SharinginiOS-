//
//  HomeViewController.h
//  Loop US
//
//  Created by Dnyaneshwar Shinde on 23/11/17.
//  Copyright © 2017 Dnyaneshwar Shinde. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "ImageSelector.h"
 

@interface HomeViewController : UIViewController <MCBrowserViewControllerDelegate, MCSessionDelegate,UIImagePickerControllerDelegate,MPMediaPickerControllerDelegate,UINavigationControllerDelegate,ImageSelectorDelegate>

@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@property (strong, nonatomic) NSURL *selectURL;
- (IBAction)connectButtonClickAction:(UIButton *)sender;
@property (strong, nonatomic) NSString *selectedMode;
- (IBAction)PhotoButtonClickAction:(UIButton *)sender;
- (IBAction)MusicButtonClickAction:(UIButton *)sender;
- (IBAction)VideoButtonClickAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

//@property (strong, nonatomic) MPMoviePlayerController *videoController;

@property (nonatomic, strong) MCBrowserViewController *browserVC;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;
@property (nonatomic, strong) MCSession *mySession;
@property (nonatomic, strong) MCPeerID *myPeerID;
@end
