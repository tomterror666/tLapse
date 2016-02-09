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

@interface BaseViewController () <FotoGeneratorDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titelLabel;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, strong) FotoGenerator *generator;

@end

@implementation BaseViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.generator = [[FotoGenerator alloc] initWithFotoView:self.cameraView inOrientation:self.interfaceOrientation];
	self.generator.delegate = self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark button handling
#pragma mark -

- (IBAction)startButtonTouched:(id)sender {
	self.startButton.enabled = NO;
	self.generator.numberOfImagesToCapture = 3;
	[self.generator startCapturing];
}

#pragma mark -
#pragma mark FotoGeneratorDelegate implementation
#pragma mark -

- (void)fotoGeneratorDidFinished:(FotoGenerator *)generator {
	[DataManager cleanup];
	NSLog(@"FERTIG");
	self.startButton.enabled = YES;
}

@end
