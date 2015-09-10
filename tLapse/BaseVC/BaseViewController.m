//
//  ViewController.m
//  tLapse
//
//  Created by Andre Heß on 27/08/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

#import "BaseViewController.h"
#import "FotoGenerator.h"

@interface BaseViewController () <FotoGeneratorDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titelLabel;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation BaseViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark button handling
#pragma mark -

- (IBAction)startButtonTouched:(id)sender {
	FotoGenerator *genertor = [[FotoGenerator alloc] initWithFotoView:self.cameraView inOrientation:self.interfaceOrientation];
	genertor.numberOfImagesToCapture = 3;
	genertor.delegate = self;
	[genertor startCapturing];
}

#pragma mark -
#pragma mark FotoGeneratorDelegate implementation
#pragma mark -

- (void)fotoGeneratorDidFinished:(FotoGenerator *)generator {
	NSLog(@"FERTIG");
}

@end
