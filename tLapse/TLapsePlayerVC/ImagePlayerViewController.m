//
//  ImagePlayerViewController.m
//  tLapse
//
//  Created by Andre Hess on 09.02.16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

#import <Photos/Photos.h>
#import "ImagePlayerViewController.h"
#import "ImagePlayerCell.h"

#define ImagePlayerCellIdentifier @"imagePlayerCellIdentifier"

@interface ImagePlayerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *playerView;
@property (nonatomic, weak) IBOutlet UIButton *finishButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;

@property (nonatomic, strong) NSArray *allImageNames;

@end

@implementation ImagePlayerViewController

- (id)initWithArrayOfImageNames:(NSArray *)imageNames {
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if (self != nil) {
		self.allImageNames = imageNames;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self configureCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Configuration
#pragma mark -

- (void)configureCollectionView {
	[self.playerView registerNib:[UINib nibWithNibName:@"ImagePlayerCell" bundle:nil] forCellWithReuseIdentifier:ImagePlayerCellIdentifier];
	self.playerView.delegate = self;
	self.playerView.dataSource = self;
}

#pragma mark -
#pragma mark Button handling
#pragma mark -

- (IBAction)finishButtonTouched:(id)sender {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)saveButtonTouched:(id)sender {
//	PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
//	PHFetchOptions *fetchOptions = [PHFetchOptions new];
//	fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", @"tLapse"];
//	PHFetchResult *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
//	__block PHAssetCollection *album = nil;
//	__weak typeof(self) weakSelf = self;
//	
//	void (^addImagesBlock)(void) = ^() {
//		[library performChanges:^{
//			NSMutableArray *assetPlaceholders = [NSMutableArray new];
//			PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:album];
//			for (NSString *imageFileName in weakSelf.allImageNames) {
//				UIImage *image = [UIImage imageWithContentsOfFile:imageFileName];
//				PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
//				PHObjectPlaceholder *assetPlaceholder = [createAssetRequest placeholderForCreatedAsset];
//				[assetPlaceholders addObject:assetPlaceholder];
//			}
//			[albumChangeRequest addAssets:assetPlaceholders];
//		} completionHandler:^(BOOL success, NSError * _Nullable error) {
//			NSLog(@"Finished adding images with: %@", (success ? @"Success" : error));
//		}];
//	};
//	
//	if ([collection count] == 0) {
//		[library performChanges:^{
//			PHAssetCollectionChangeRequest *createAlbumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"tLapse"];
//			PHObjectPlaceholder *assetCollectionPlaceholder = [createAlbumRequest placeholderForCreatedAssetCollection];
//		} completionHandler:^(BOOL success, NSError * _Nullable error) {
//			if (success) {
//				addImagesBlock();
//			} else {
//				NSLog(@"Finished adding album with error: %@", error);
//			}
//		}];
//	} else {
//		album = collection.firstObject;
//		addImagesBlock();
//	}
	
	PHAssetCollection *album = [self tLapseAlbum];
	if (album == nil) {
		[self addTLapseAlbum];
		album = [self tLapseAlbum];
	}
	[self addImagesToTLapseAlbum:album];
}

- (PHAssetCollection *)tLapseAlbum {
	PHFetchOptions *fetchOptions = [PHFetchOptions new];
	fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", @"tLapse"];
	PHFetchResult *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
	return [collection count] > 0 ? collection.firstObject : nil;
}

- (void)addTLapseAlbum {
	__weak typeof(self) weakSelf = self;
	[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
		PHAssetCollectionChangeRequest *createAlbumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"tLapse"];
		__unused PHObjectPlaceholder *assetCollectionPlaceholder = [createAlbumRequest placeholderForCreatedAssetCollection];
	} completionHandler:^(BOOL success, NSError * _Nullable error) {
		if (success) {
			[weakSelf addImagesToTLapseAlbum:[weakSelf tLapseAlbum]];
		} else {
			NSLog(@"Finished adding album with error: %@", error);
		}
	}];
}

- (void)addImagesToTLapseAlbum:(PHAssetCollection *)album {
	[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
		NSMutableArray *assetPlaceholders = [NSMutableArray new];
		PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:album];
		for (NSString *imageFileName in self.allImageNames) {
			UIImage *image = [UIImage imageWithContentsOfFile:imageFileName];
			PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
			PHObjectPlaceholder *assetPlaceholder = [createAssetRequest placeholderForCreatedAsset];
			[assetPlaceholders addObject:assetPlaceholder];
		}
		[albumChangeRequest addAssets:assetPlaceholders];
	} completionHandler:^(BOOL success, NSError * _Nullable error) {
		NSLog(@"Finished adding images with: %@", (success ? @"Success" : error));
	}];
}

#pragma mark -
#pragma mark UICollectionView things
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.allImageNames count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	ImagePlayerCell *cell = (ImagePlayerCell *)[self.playerView dequeueReusableCellWithReuseIdentifier:ImagePlayerCellIdentifier forIndexPath:indexPath];
	[cell updateWithImageFileName:self.allImageNames[indexPath.row]];
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return self.playerView.bounds.size;
}

@end
