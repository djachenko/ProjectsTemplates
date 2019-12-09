//
// Created by Igor Djachenko on 16/03/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface OverlaysManager : NSObject
- (void)registerOverlay:(UIImage *)overlay withSample:(UIImage *)sample;

- (void)recognize:(UIImage *)frame;

- (NSUInteger)updateFrame:(UIImage *)frame;

- (UIImage *)mergedOverlay;
@end