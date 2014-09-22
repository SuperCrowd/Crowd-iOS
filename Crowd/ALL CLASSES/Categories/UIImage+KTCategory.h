//
//  UIImageAdditions.h
//  Sample
//
//  Created by Kirby Turner on 2/7/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import <float.h>

@interface UIImage (KTCategory)

- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize;
- (UIImage *)imageScaleAndCropToMaxSize:(CGSize)newSize;
- (UIImage *)imageReduceSize:(CGSize)newSize;

- (UIImage *)cropImage_From_Center:(CGSize)fitSize;
-(UIImage*)imageCrop_Square:(UIImage *)image scaledToSize:(CGSize)newSize;
@end
