//
// Created by Igor Djachenko on 22/02/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "UIImage+CvConversion.h"

#import "FrameWarper.h"
#import "CGSize+Transposing.h"


cv::Mat countWarp3(cv::Mat from, cv::Mat to) {
    cv::Mat warpMatrix = cv::Mat::eye(3, 3, CV_32F);

    cv::findTransformECC(
            to,
            from,
            warpMatrix,
            cv::MOTION_HOMOGRAPHY,
            cv::TermCriteria(cv::TermCriteria::COUNT + cv::TermCriteria::EPS, 50, 0.001)
    );

    return warpMatrix;
}







@interface FrameWarper()

@property (nonatomic) cv::Mat previousFrame;
@property (nonatomic) cv::Mat currentFrame;

@end


@implementation FrameWarper

- (instancetype)init {
    self = [super init];

    if (self) {
        self.currentFrame = cv::Mat();
        self.previousFrame = cv::Mat();
    }

    return self;
}


- (cv::Mat)prepareImage:(UIImage *)image {
    auto matrix = [image toCVMatrix];

    double size = 400.0;

    double xScale = size / image.size.width;
    double yScale = size / image.size.height;

    double scale = MIN(MIN(xScale, yScale), 1);

    cv::Mat resized;

    cv::resize(matrix, resized, cv::Size(), scale, scale);

    cv::Mat rotated;

    cv::rotate(resized, rotated, cv::ROTATE_90_CLOCKWISE);

    cv::Mat grayed;

    cv::cvtColor(rotated, grayed, CV_RGBA2GRAY);

    return grayed;
}

- (NSInteger)registerFrame:(UIImage *)frame {
    auto newFrame = [self prepareImage:frame];

    self.previousFrame = self.currentFrame;
    self.currentFrame = newFrame;

    auto from = self.previousFrame;
    auto to = self.currentFrame;

    id <FrameWarperDelegate> delegate = self.delegate;


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^() {
        cv::Mat warp;

        if (from.empty() || to.empty()) {
            warp = cv::Mat::eye(3, 3, CV_32F);
        }
        else {
            warp = countWarp3(from, to);
        }

        [delegate countedWarp:warp];
    });

    return 0;
}


@end
