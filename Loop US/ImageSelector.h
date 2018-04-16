//
//  ImageSelector.h
//  AssetMediaPlayer
//
//  Created by Dnyaneshwar Shinde on 24/11/17.
//  Copyright © 2017 Dnyaneshwar Shinde. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ImageSelector;

@protocol ImageSelectorDelegate <NSObject>
-(void)ims_PickerController:(ImageSelector*)picker didFinishPickingMediaItems:(NSArray*)items;
@end

 @interface ImageSelector : UIViewController <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    id <ImageSelectorDelegate> ims_delegate;
}
@property(nonatomic,strong)id <ImageSelectorDelegate>ims_delegate;
@end
