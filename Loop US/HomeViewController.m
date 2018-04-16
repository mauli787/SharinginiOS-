//
//  HomeViewController.m
//  Loop US
//
//  Created by Dnyaneshwar Shinde on 23/11/17.
//  Copyright © 2017 Dnyaneshwar Shinde. All rights reserved.
//

#import "HomeViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ImageViewViewController.h"

@interface HomeViewController ()
{
    __block BOOL _isSendData;
    NSMutableArray *marrFileData, *marrReceiveData;
    NSUInteger noOfdata, noOfDataSend;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    marrFileData = [[NSMutableArray alloc] init];
    marrReceiveData = [[NSMutableArray alloc] init];
   
    
}

- (IBAction)PhotoButtonClickAction:(UIButton *)sender {
    self.selectedMode = @"Photo";
    
//    ImageSelector *selector = [[ImageSelector alloc] init];
//    selector.ims_delegate = self;
//    [self presentViewController:selector animated:YES completion:nil];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
     picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)MusicButtonClickAction:(UIButton *)sender {
    
    self.selectedMode = @"Music";
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
   
}
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem *theChosenSong = [[mediaItemCollection items]objectAtIndex:0];
    NSString *songTitle = [theChosenSong valueForProperty:MPMediaItemPropertyTitle];
    NSURL *assetURL = [theChosenSong valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset  *songAsset  = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    NSLog(@"%@  %@",songTitle,songAsset);
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    
   [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController.navigationItem setTitle:@"Send"];
}

- (IBAction)VideoButtonClickAction:(UIButton *)sender {

    self.selectedMode = @"Video";
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
        videoPicker.delegate = self;
        videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
        videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        [self presentViewController:videoPicker animated:YES completion:nil];
    }
}
 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"%@",info);
    
     [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if ([self.selectedMode isEqualToString:@"Video"]) {
          self.selectURL = info[UIImagePickerControllerMediaURL];
        
         [self sendDataURLString:self.selectURL];
    }
    else if ([self.selectedMode isEqualToString:@"Photo"]) {
        if (@available(iOS 11.0, *)) {
             self.selectURL = info[UIImagePickerControllerImageURL];
             [self sendDataURLString:self.selectURL];
            
        } else {
            
            UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
            [self sendImage:chosenImage];
            
        }
   }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma if iOS 10
-(void)sendImage:(UIImage *)image
{
    [marrFileData removeAllObjects];
    
    NSData *sendData = UIImagePNGRepresentation(image);
    NSUInteger length = [sendData length];
    NSUInteger chunkSize = 100 * 1024;
    NSUInteger offset = 0;
    do {
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[sendData bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        NSLog(@"chunk length : %lu",(unsigned long)chunk.length);
        
        [marrFileData addObject:[NSData dataWithData:chunk]];
        offset += thisChunkSize;
    } while (offset < length);
    
    noOfdata = [marrFileData count];
    noOfDataSend = 0;
    
    if ([marrFileData count] > 0) {
        
        NSArray *Arr =[self.mySession connectedPeers];
        
        if (Arr.count > 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                  [self.mySession sendData:[marrFileData objectAtIndex:noOfDataSend] toPeers:[self.mySession connectedPeers] withMode:MCSessionSendDataReliable error:nil];
            });
            
            
        }else{
            [self invokeAlertMethod:@"Fail" Body:@"Please connect with other device." Delegate:self];
        } 
    }
}
#pragma if iOS 11 letter
-(void)sendDataURLString:(NSURL *)locationurl
{
    [marrFileData removeAllObjects];
    NSString *sendStr = [[locationurl absoluteString]
                         stringByReplacingOccurrencesOfString:@"file:///private" withString:@""];
    
         NSData *sendData = [NSData dataWithContentsOfFile:sendStr];
         NSUInteger length = [sendData length];
         NSUInteger chunkSize = 100 * 1024;
         NSUInteger offset = 0;
    do {
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[sendData bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        NSLog(@"chunk length : %lu",(unsigned long)chunk.length);
        
        [marrFileData addObject:[NSData dataWithData:chunk]];
        offset += thisChunkSize;
    } while (offset < length);
    
    noOfdata = [marrFileData count];
    noOfDataSend = 0;
         if ([marrFileData count] > 0) {
             NSArray *Arr =[self.mySession connectedPeers];
       if (Arr.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                [self.mySession sendData:[marrFileData objectAtIndex:noOfDataSend] toPeers:[self.mySession connectedPeers] withMode:MCSessionSendDataReliable error:nil];
           });
           
        }else{
            [self invokeAlertMethod:@"Fail" Body:@"Please connect with other device." Delegate:self];
        }
    }
}

#pragma marks MCBrowserViewControllerDelegate

- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    return YES;
}

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
     [marrReceiveData removeAllObjects];
    [self.browserVC dismissViewControllerAnimated:YES completion:^(void){
        
        [self invokeAlertMethod:@"Connected Sucessfully" Body:@"Both device connected successfully." Delegate:nil];
    }];
    
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [self.browserVC dismissViewControllerAnimated:YES completion:nil];
}
#pragma marks MCSessionDelegate
// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"data receiveddddd : %lu",(unsigned long)data.length);
    
    if (data.length > 0) {
        if (data.length < 2) {
            noOfDataSend++;
            NSLog(@"noofdatasend : %lu",(unsigned long)noOfDataSend);
            NSLog(@"array count : %lu",(unsigned long)marrFileData.count);
            if (noOfDataSend < ([marrFileData count])) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                 
                      [self.mySession sendData:[marrFileData objectAtIndex:noOfDataSend] toPeers:[self.mySession connectedPeers] withMode:MCSessionSendDataReliable error:nil];
                });
            }else {
                [self.mySession sendData:[@"File Transfer Done" dataUsingEncoding:NSUTF8StringEncoding] toPeers:[self.mySession connectedPeers] withMode:MCSessionSendDataReliable error:nil];
            }
        } else {
            
            if ([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqualToString:@"File Transfer Done"]) {
                
                    [self appendFileData];
               
            }else {
                
              [self.mySession sendData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] toPeers:[self.mySession connectedPeers] withMode:MCSessionSendDataReliable error:nil];
               
                [marrReceiveData addObject:data];
            }
        }
    }
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"did receive stream");
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"start receiving");
}

- (void)session:(MCSession *)session
    didReceiveCertificate:(NSArray *)certificate
                 fromPeer:(MCPeerID *)peerID
       certificateHandler:(void (^)(BOOL))certificateHandler
{
    if (certificateHandler != nil) {
        certificateHandler(YES);
        
    }else{
        
        NSLog(@"Certificate is nil");
    }
}

#pragma Definfe here MCSession Delegate method

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"finish receiving resource :  %@ ,%@",resourceName,peerID);
}
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"change state : %ld",(long)state);
}
 
- (IBAction)connectButtonClickAction:(UIButton *)sender {
    
    if (sender.tag == 1) {
        if (!self.mySession) {
            [self setUpMultipeer];
        }
        [self showBrowserVC];
    }else{
        
        if (!self.mySession) {
            [self setUpMultipeer];
        }
        [self showBrowserVC];
    }
}
#pragma mark - Wifi Sharing Methods

-(void)setUpMultipeer
{
    
    self.myPeerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
   
   // self.mySession = [[MCSession alloc] initWithPeer:self.myPeerID];
    
    self.mySession = [[MCSession alloc] initWithPeer:self.myPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    
    self.mySession.delegate = self;
    
    self.browserVC = [[MCBrowserViewController alloc] initWithServiceType:@"chat" session:self.mySession];
    self.browserVC.delegate = self;
    self.browserVC.minimumNumberOfPeers = kMCSessionMinimumNumberOfPeers;
    self.browserVC.maximumNumberOfPeers = kMCSessionMaximumNumberOfPeers;
    
    self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"chat" discoveryInfo:nil session:self.mySession];
    [self.advertiser start];
}

-(void)showBrowserVC
{
    [self presentViewController:self.browserVC animated:YES completion:nil];
}

-(void)stopWifiSharing:(BOOL)isClear
{
    if(isClear && self.mySession != nil){
        [self.mySession disconnect];
        [self.mySession setDelegate:nil];
        self.mySession = nil;
        self.browserVC = nil;
    }
}

-(void)appendFileData
{
    
    NSMutableData *fileData = [NSMutableData data];
    for (int i = 0; i < [marrReceiveData count]; i++) {
        [fileData appendData:[marrReceiveData objectAtIndex:i]];
    }
    
    if ([self.selectedMode isEqualToString:@"Video"]) {
        
        NSString *filePath = [self documentsPathForFileName:@"/video.mp4"];
        NSURL *videoFileURL =  [NSURL fileURLWithPath:filePath];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            AVPlayerViewController * _moviePlayer1 = [[AVPlayerViewController alloc] init];
            _moviePlayer1.player = [AVPlayer playerWithURL:videoFileURL];
            [self presentViewController:_moviePlayer1 animated:YES completion:^{
                [_moviePlayer1.player play];
            }];
           
        }];
        
    }else if([self.selectedMode isEqualToString:@"Photo"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ImageViewViewController *imgView =[self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewViewController"];
            imgView.fileDatarecived = [NSMutableData dataWithData:fileData];
            [self.navigationController pushViewController:imgView animated:YES];
        });
    }
    else if([self.selectedMode isEqualToString:@"Music"]) {
        
        NSString *filePath = [self documentsPathForFileName:@"/Songs.mp3"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                AVAudioPlayer *audioPlayer;
                NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];
                audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
                audioPlayer.numberOfLoops = -1;
                [audioPlayer play];
            }];
        });
    }
   
}

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
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
