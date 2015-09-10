//
//  DataManager.h
//  tLapse
//
//  Created by Andre Heß on 27/08/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataManager : NSObject

+ (DataManager *)defaultManager;

+ (void)storeData:(NSData *)data withFileName:(NSString *)fileName;

+ (NSArray *)getAllStoredFileNames;

+ (NSData *)getFileDataAtIndex:(NSUInteger)index;

+ (void)cleanup;

@end
