//
// Created by Igor Djachenko on 22/02/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageWarper : NSObject

- (instancetype)initWithFirstFrame:(UIImage *)frame andOverlay:(UIImage *)overlay;

- (NSInteger)addNewFrame:(UIImage *)frame;

- (UIImage *)warpedOverlay;

- (UIImage *)frame1;

- (UIImage *)frame2;

- (UIImage *)over;

@end