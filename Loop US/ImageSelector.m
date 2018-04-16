//
//  ImageSelector.m
//  AssetMediaPlayer
//
//  Created by Dnyaneshwar Shinde on 24/11/17.
//  Copyright © 2017 Dnyaneshwar Shinde. All rights reserved.
//

#import "ImageSelector.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageSelector ()
{
    __block NSMutableArray *thumbsArr;
    __block NSMutableArray *urlArray;
    NSMutableArray *selectedIndexArr;
}
@end

@implementation ImageSelector
@synthesize ims_delegate;

-(id)init{
    self = [super init];
    if (self) {
        
        thumbsArr = [[NSMutableArray alloc] init];
        urlArray = [[NSMutableArray alloc] init];
        selectedIndexArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadAssets{
    __block  NSDate *now = [NSDate date];
    
    __block NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSLog(@"Start: %@",[dateFormatter stringFromDate:now]);
    
    __block ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
      [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
     // [group setAssetsFilter:[ALAssetsFilter allVideos]];
        
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            if (alAsset) {
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                UIImage *latestPhotoThumbnail =  [UIImage imageWithCGImage:[alAsset thumbnail]];
                
                [urlArray addObject:representation.url];
                [thumbsArr addObject:latestPhotoThumbnail];
                
                representation = nil;
                latestPhotoThumbnail = nil;
            }else{
                now = [NSDate date];
                NSLog(@"End: %@",[dateFormatter stringFromDate:now]);
                now = nil;
                library = nil;
                dateFormatter = nil;
                
                [_collectionView reloadData];
            }
        }];
    } failureBlock: ^(NSError *error) {
        NSLog(@"No groups: %@",error);
    }];
}

- (void)viewDidLoad
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    CGRect controllerFrame = self.view.frame;
    
    controllerFrame.origin.y = 44;
    controllerFrame.size.height-=44;
    
    UIToolbar *controllerBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, controllerFrame.size.width, 44)];
   
    controllerBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    
    [cancel setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blueColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    [done setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blueColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    [controllerBar setItems:@[cancel,flexibleItem,done] animated:YES]; 
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    _collectionView=[[UICollectionView alloc] initWithFrame:controllerFrame collectionViewLayout:layout];
    _collectionView.allowsMultipleSelection = YES;
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"im_cell_identifier"];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:controllerBar];
    [self.view addSubview:_collectionView];
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadAssets];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [thumbsArr count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"im_cell_identifier" forIndexPath:indexPath];
    
    cell.layer.borderWidth = 2.0;
    cell.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
    cell.layer.cornerRadius = 10 ;
    
    
    UIImageView *imgView = (UIImageView*)[cell viewWithTag:21];
    UIImageView *checked = (UIImageView*)[cell viewWithTag:44];
    
    if (imgView==nil) {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
        imgView.tag =21;
        imgView.center = CGPointMake(cell.frame.size.width/2, cell.frame.size.height/2);
        cell.backgroundColor = [UIColor whiteColor];
        [cell addSubview:imgView];
    }
    
    if (checked==nil) {
        checked = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        checked.tag = 44;
        checked.center = CGPointMake(cell.frame.size.width/2, cell.frame.size.height/2);
        [cell addSubview:checked];
    }
    
    if (cell.selected) {
        [checked setImage:[UIImage imageNamed:@"check.png"]];
        [cell setBackgroundColor:[UIColor redColor]];
    }else{
        [checked setImage:nil];
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    
    [imgView setImage:[thumbsArr objectAtIndex:indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(150,150);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(320, 10);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark -  Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([selectedIndexArr count]==10) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Limit Exceed" message:@"You cannot select more than 10 images." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    UIImageView *checked = (UIImageView*)[cell viewWithTag:44];
    [checked setImage:[UIImage imageNamed:@"check.png"]];
    
    NSURL *url = [urlArray objectAtIndex:indexPath.row];
    [selectedIndexArr addObject:url];
    
    url = nil;
    checked = nil;
    cell = nil;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    UIImageView *checked = (UIImageView*)[cell viewWithTag:44];
    [checked setImage:nil];
    
    NSURL *url = [urlArray objectAtIndex:indexPath.row];
    [selectedIndexArr removeObject:url];
    
    cell = nil;
    checked = nil;
    url = nil;
}

#pragma mark - BarButton Methods

-(void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)done
{
    __block NSMutableArray *imageArray = [[NSMutableArray alloc] initWithCapacity:[selectedIndexArr count]];
    
    [selectedIndexArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:obj resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
         
            [imageArray addObject:latestPhoto];
            
            if ([imageArray count]==[selectedIndexArr count]) {
                if ([self.ims_delegate respondsToSelector:@selector(ims_PickerController:didFinishPickingMediaItems:)]) {
                    [self.ims_delegate ims_PickerController:self didFinishPickingMediaItems:imageArray];
                }
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Failure picking media");
        }];
    }];
}

-(void)viewDidDisappear:(BOOL)animated{
    thumbsArr = nil;
    urlArray = nil;
    selectedIndexArr = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
