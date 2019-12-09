//
// Created by Igor Djachenko on 22/02/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FrameWarperDelegate

- (void)countedWarp:(cv::Mat)warp;

@end

@interface FrameWarper : NSObject

@property (weak) id<FrameWarperDelegate> delegate;

- (NSInteger)registerFrame:(UIImage *)frame;

@end