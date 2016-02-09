//
//  ConfigurationViewController.m
//  tLapse
//
//  Created by Andre Hess on 09.02.16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "Configuration.h"

@interface ConfigurationViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *numberOfImagesField;
@property (nonatomic, weak) IBOutlet UITextField *timeIntervalField;
@property (nonatomic, weak) IBOutlet UIButton *finishButton;

@end

@implementation ConfigurationViewController

- (id)init {
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if (self != nil) {
		
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self configureTextFields];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Configuration
#pragma mark -

- (void)configureTextFields {
	self.numberOfImagesField.text = [NSString stringWithFormat:@"%ld", (long)[Configuration sharedConfiguration].numberOfImagesToShoot];
	self.timeIntervalField.text = [NSString stringWithFormat:@"%.02f", [Configuration sharedConfiguration].timeIntervalBetweenImages];
}

#pragma mark -
#pragma mark Button handling
#pragma mark -

- (IBAction)finishButtonTouched:(id)sender {
	[self.view endEditing:YES];
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark UITextFieldDelegate
#pragma mark -

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if ([textField isEqual:self.numberOfImagesField]) {
		[Configuration sharedConfiguration].numberOfImagesToShoot = [textField.text integerValue];
	} else {
		[Configuration sharedConfiguration].timeIntervalBetweenImages = [textField.text floatValue];
	}
}


@end
