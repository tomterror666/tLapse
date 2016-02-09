//
//  ImagePlayerCell.m
//  tLapse
//
//  Created by Andre Hess on 09.02.16.
//  Copyright © 2016 Andre Heß. All rights reserved.
//

#import "ImagePlayerCell.h"

@interface ImagePlayerCell ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation ImagePlayerCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)updateWithImageFileName:(NSString *)imageFileName {
	self.imageView.image = [UIImage imageWithContentsOfFile:imageFileName];
}

@end
