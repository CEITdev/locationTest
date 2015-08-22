//
//  UIImage+ResizeImage.h
//  LocationTest
//
//  Created by Mac on 22.08.15.
//  Copyright (c) 2015 CEIT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (ResizeImage)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
