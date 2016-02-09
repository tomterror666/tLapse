//
//  Configuration.m
//  tLapse
//
//  Created by Andre Hess on 09.02.16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

#import "Configuration.h"

#define NumberOfImagesKey	@"numberOfImagesKey"
#define TimeIntevalKey		@"timeIntervalKey"

static Configuration *sharedInstance = nil;

@interface Configuration ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation Configuration

+ (id)sharedConfiguration {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [Configuration new];
	});
	return sharedInstance;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		self.userDefaults = [NSUserDefaults standardUserDefaults];
	}
	return self;
}

- (NSInteger)numberOfImagesToShoot {
	return [self.userDefaults integerForKey:NumberOfImagesKey];
}

- (void)setNumberOfImagesToShoot:(NSInteger)numberOfImagesToShoot {
	[self.userDefaults setInteger:numberOfImagesToShoot forKey:NumberOfImagesKey];
	[self.userDefaults synchronize];
}

- (NSTimeInterval)timeIntervalBetweenImages {
	return [self.userDefaults floatForKey:TimeIntevalKey];
}

- (void)setTimeIntervalBetweenImages:(NSTimeInterval)timeIntervalBetweenImages {
	[self.userDefaults setFloat:timeIntervalBetweenImages forKey:TimeIntevalKey];
	[self.userDefaults synchronize];
}

@end
