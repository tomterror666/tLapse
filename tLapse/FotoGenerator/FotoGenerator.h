//
//  FotoGenerator.h
//  tLapse
//
//  Created by Andre Heß on 27/08/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FotoGenerator;

@protocol FotoGeneratorDelegate <NSObject>

- (void)fotoGeneratorDidFinished:(FotoGenerator *)generator;

@end

@interface FotoGenerator : NSObject

@property (nonatomic, assign) NSUInteger numberOfImagesToCapture;
@property (nonatomic, assign) NSTimeInterval captureTime;
@property (nonatomic, assign) id<FotoGeneratorDelegate> delegate;

- (id)initWithFotoView:(UIView *)fotoView inOrientation:(UIInterfaceOrientation)orientation;

- (void)startCapturing;

@end
