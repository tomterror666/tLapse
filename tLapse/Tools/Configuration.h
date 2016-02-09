//
//  Configuration.h
//  tLapse
//
//  Created by Andre Hess on 09.02.16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configuration : NSObject

@property (nonatomic, assign) NSInteger numberOfImagesToShoot;
@property (nonatomic, assign) NSTimeInterval timeIntervalBetweenImages;

+ (Configuration *)sharedConfiguration;

@end
