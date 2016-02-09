//
//  DataManager.m
//  tLapse
//
//  Created by Andre Heß on 27/08/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()

@property (nonatomic, strong) NSString *basePath;
@property (nonatomic, strong) NSFileManager *fileManager;

@end


@implementation DataManager

- (id)init {
	self = [super init];
	if (self != nil) {
		self.fileManager = [NSFileManager defaultManager];
		[self configureBasePath];
		[self.fileManager createDirectoryAtPath:self.basePath
					withIntermediateDirectories:YES
									 attributes:nil
										  error:NULL];
	}
	return self;
}

+ (DataManager *)defaultManager {
	static dispatch_once_t onceToken;
	static DataManager *defaultManager = nil;
	dispatch_once(&onceToken, ^{
		defaultManager = [DataManager new];
	});
	return defaultManager;
}

+ (void)storeData:(NSData *)data withFileName:(NSString *)fileName {
	DataManager* dataManager = [DataManager defaultManager];
	[data writeToFile:[dataManager.basePath stringByAppendingPathComponent:fileName] atomically:YES];
//	UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], nil, nil, NULL);
}

+ (NSArray *)getAllStoredFileNames {
	DataManager* dataManager = [DataManager defaultManager];
	NSArray *allNames = [dataManager.fileManager contentsOfDirectoryAtPath:dataManager.basePath error:NULL];
	return allNames;
}

+ (NSData *)getFileDataAtIndex:(NSUInteger)index {
	NSArray *fileNames = [DataManager getAllStoredFileNames];
	NSString *fileName = [fileNames objectAtIndex:index];
	NSData *result = [NSData dataWithContentsOfFile:[[DataManager defaultManager].basePath stringByAppendingPathComponent:fileName]];
	return result;
}

+ (void)cleanup {
	NSArray *fileNames = [DataManager getAllStoredFileNames];
	NSString *basePath = [DataManager defaultManager].basePath;
	for (NSString *fileName in fileNames) {
		[[DataManager defaultManager].fileManager removeItemAtPath:[basePath stringByAppendingPathComponent:fileName] error:NULL];
	}
}

- (void)configureBasePath {
	NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] == 0) {
		self.basePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ImageData"];
	} else {
		self.basePath = [paths[0] stringByAppendingPathComponent:@"ImageData"];
	}
}

@end
