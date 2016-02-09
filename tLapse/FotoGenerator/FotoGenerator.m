//
//  FotoGenerator.m
//  tLapse
//
//  Created by Andre Heß on 27/08/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

#import "FotoGenerator.h"
#import "DataManager.h"
#import "Configuration.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface FotoGenerator ()

@property (nonatomic, strong) UIView *fotoView;
@property (nonatomic, assign) UIInterfaceOrientation videoOrientation;
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) NSTimer *generatorTimer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;

@property (nonatomic, assign) NSUInteger imageCounter;

@end

@implementation FotoGenerator

- (id)initWithFotoView:(UIView*)fotoView inOrientation:(UIInterfaceOrientation)orientation {
	self = [super init];
	if (self != nil) {
		self.fotoView = fotoView;
		self.videoOrientation = orientation;
		self.numberOfImagesToCapture = 0;
		self.captureTime = 0;
		self.imageCounter = 0;
		self.dataManager = [DataManager defaultManager];
		self.session = [AVCaptureSession new];
		[self configureCaptureSession];
		[self configureFotoView];
		self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
		[self configureCaptureDevice];
		[self configureCaptureConnection];
		[self.session startRunning];
		[self getImageAndSave:NO];
	}
	return self;
}

- (void)startCapturing {
	[self configureTimer];
	[self addTimerToRunloop];
}

#pragma mark -
#pragma mark configure capture devices
#pragma mark -

- (void)configureCaptureSession {
	self.session.sessionPreset = AVCaptureSessionPresetHigh;
}

- (void)configureFotoView {
	if (self.fotoView != nil) {
		AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: self.session];
		previewLayer.frame = self.fotoView.bounds;
		[self.fotoView.layer addSublayer:previewLayer];
	}
}

- (void)configureCaptureDevice {
	NSError *error = nil;
	[self.device lockForConfiguration:&error];
	if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		self.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
	}
	if (self.device.smoothAutoFocusSupported) {
		self.device.smoothAutoFocusEnabled = YES;
	}
	if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
		self.device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
	}
	if (self.device.lowLightBoostSupported) {
		self.device.automaticallyEnablesLowLightBoostWhenAvailable = YES;
	}
	self.device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
	self.device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
	[self.device unlockForConfiguration];
	[self.session addInput:self.input];
}

- (void)configureCaptureConnection {
	self.stillImageOutput = [AVCaptureStillImageOutput new];
	self.stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
	//	stillImageOutput.outputSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
	self.stillImageOutput.highResolutionStillImageOutputEnabled = YES;
	[self.session addOutput:self.stillImageOutput];
	self.videoConnection = nil;
	NSArray *connections = [self.stillImageOutput connections];
	for (AVCaptureConnection *connection in connections) {
		NSArray *inputPorts = connection.inputPorts;
		for (AVCaptureInputPort *port in inputPorts) {
			if (port.mediaType == AVMediaTypeVideo) {
				self.videoConnection = connection;
				break;
			}
		}
		if (self.videoConnection != nil) {
			break;
		}
	}
	if (self.videoConnection.isVideoOrientationSupported) {
		switch (self.videoOrientation) {
			case UIInterfaceOrientationLandscapeLeft:
				self.videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
	    		break;
			case UIInterfaceOrientationLandscapeRight:
				self.videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
				break;
			case UIInterfaceOrientationPortrait:
				self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
				break;
			default:
    break;
		}
	}
}

#pragma mark -
#pragma mark timer handling
#pragma mark -

- (void)configureTimer {
	NSTimeInterval interval = [Configuration sharedConfiguration].timeIntervalBetweenImages == 0 ? 5 : [Configuration sharedConfiguration].timeIntervalBetweenImages;
	self.generatorTimer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(handleTimerEvent:) userInfo:nil repeats:YES];
}

- (void)addTimerToRunloop {
	[[NSRunLoop currentRunLoop] addTimer:self.generatorTimer forMode: NSDefaultRunLoopMode];
}

- (void)stopTimeLapsing {
	[self.generatorTimer invalidate];
	[self configureTimer];
	if ([self.delegate respondsToSelector:@selector(fotoGeneratorDidFinished:)]) {
		[self.delegate fotoGeneratorDidFinished:self];
	}
	[self.session stopRunning];
}

- (void)handleTimerEvent:(NSTimer *)timer {
	NSDateFormatter *formatter = [NSDateFormatter new];
	formatter.dateStyle = NSDateFormatterShortStyle;
	formatter.timeStyle = NSDateFormatterLongStyle;
	NSLog(@"begin to generate image now: %@", [formatter stringFromDate:[NSDate date]]);
	[self getImage];
	self.imageCounter++;
}

#pragma mark -
#pragma mark getting images
#pragma mark -

- (void)getImage {
	[self getImageAndSave:YES];
}

- (void)getImageAndSave:(BOOL)doSave {
	__weak typeof(self) weakSelf = self;
	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:self.videoConnection
												  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
													  if (doSave) {
														  NSData *imageData = [weakSelf imageDataFromSampleBuffer:imageDataSampleBuffer];
														  [DataManager storeData:imageData withFileName:[NSString stringWithFormat:@"timeLapsImage_%ld", (long)weakSelf.imageCounter]];
														  NSDateFormatter *formatter = [NSDateFormatter new];
														  formatter.dateStyle = NSDateFormatterShortStyle;
														  formatter.timeStyle = NSDateFormatterLongStyle;
														  NSLog(@"finished to generate image now: %@", [formatter stringFromDate:[NSDate date]]);
														  if (weakSelf.imageCounter == weakSelf.numberOfImagesToCapture) {
															  [weakSelf stopTimeLapsing];
														  }
													  }
												  }];
}

- (NSData *)imageDataFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	if (imageBuffer == nil) {
		return [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
	} else {
		CVPixelBufferLockBaseAddress(imageBuffer, 0);
		void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
		size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
		size_t width = CVPixelBufferGetWidth(imageBuffer);
		size_t height = CVPixelBufferGetHeight(imageBuffer);
		CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, CGColorSpaceCreateDeviceRGB(), (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
		CGImageRef imageRef = CGBitmapContextCreateImage(context);
		
		CGContextRef resultCtx = CGBitmapContextCreate(nil, height, width, 8, height * 4, CGColorSpaceCreateDeviceRGB(), (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
		//CGContextRotateCTM(resultCtx, -M_2_PI);
		CGContextDrawImage(resultCtx, CGRectMake(/*CGFloat((height-width)/2+height)*/0, /*CGFloat((width-height)/2)*/0, width, height), imageRef);
		//			CGContextRotateCTM(resultCtx, CGFloat(-M_2_PI))
		
		return UIImageJPEGRepresentation([UIImage imageWithCGImage: CGBitmapContextCreateImage(resultCtx)], 0.8);
	}
}

@end
