//
//  ViewController.m
//  tLapse
//
//  Created by Andre Heß on 27/08/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

#import "BaseViewController.h"
#import "FotoGenerator.h"
#import "DataManager.h"
#import "ImagePlayerViewController.h"
#import "ConfigurationViewController.h"
#import "Configuration.h"

@interface BaseViewController () <FotoGeneratorDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titelLabel;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *configureButton;

@property (nonatomic, strong) FotoGenerator *generator;

@end

@implementation BaseViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self configureGenerator];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark Configuration
#pragma mark -

- (void)configureGenerator {
	self.generator = [[FotoGenerator alloc] initWithFotoView:self.cameraView inOrientation:self.interfaceOrientation];
	self.generator.delegate = self;
}

#pragma mark -
#pragma mark button handling
#pragma mark -

- (IBAction)startButtonTouched:(id)sender {
	self.startButton.enabled = NO;
	[DataManager cleanup];
	self.generator.numberOfImagesToCapture = [Configuration sharedConfiguration].numberOfImagesToShoot == 0 ? 3 : [Configuration sharedConfiguration].numberOfImagesToShoot;
	[self.generator startCapturing];
}

- (IBAction)playButtonTouched:(id)sender {
	NSArray *allImageFilesNames = [DataManager getAllStoredFileNames];
	if ([allImageFilesNames count] > 0) {
		ImagePlayerViewController *playerController = [[ImagePlayerViewController alloc] initWithArrayOfImageNames:allImageFilesNames];
		[self presentViewController:playerController animated:YES completion:NULL];
	}
}

- (IBAction)configureButtonTouched:(id)sender {
	ConfigurationViewController *controller = [ConfigurationViewController new];
	[self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark -
#pragma mark FotoGeneratorDelegate implementation
#pragma mark -

- (void)fotoGeneratorDidFinished:(FotoGenerator *)generator {
	NSLog(@"FERTIG");
	self.startButton.enabled = YES;
	self.playButton.enabled = YES;
	[self configureGenerator];
}

@end
