//
// Created by Igor Djachenko on 22/02/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "UIImage/"

#import "ImageWarper.h"
#import "CGSize+Transposing.h"


void printMat(const cv::Mat mat) {
    NSMutableString *matrixString = [NSMutableString stringWithString:@"\n"];

    for (int y = 0; y < mat.rows; ++y) {
        for (int x = 0; x < mat.cols; ++x) {
            [matrixString appendFormat:@"%.2f ", mat.at<float>(y, x)];
//            [matrixString appendFormat:@"%d ", mat.at<unsigned char>(y, x)];
        }

        [matrixString appendString:@"\n"];
    }

    NSLog(matrixString);
}

cv::Mat countWarp(cv::Mat from, cv::Mat to) {
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

cv::Mat eyeWarp() {
    return cv::Mat::eye(3, 3, CV_32F);
}

@interface WarpResult: NSObject

@property (nonatomic) NSUInteger index;
@property (nonatomic) cv::Mat warp;

@end

@implementation WarpResult

- (instancetype)initWithWarp:(cv::Mat)warp andIndex:(NSUInteger)index {
    self = [super init];

    if (self) {
        self.warp = warp;
        self.index = index;
    }

    return self;
}


@end

@interface ImageWarper()

@property (nonatomic) cv::Mat previousFrame;
@property (nonatomic) cv::Mat currentFrame;

@property (nonatomic) cv::Size frameSize;
@property (nonatomic) cv::Mat initialOverlay;

@property (nonatomic) NSLock *framesLock;
@property (nonatomic) NSCondition *queueLock;

@property (nonatomic) NSUInteger frameCount;
@property (nonatomic) NSMutableArray<WarpResult *> *warpQueue;


@property (nonatomic) NSUInteger resultsCount;
@property (nonatomic) NSLock *resultCountLock;


@end


@implementation ImageWarper

- (instancetype)initWithFirstFrame:(UIImage *)frame andOverlay:(UIImage *)overlay {
    self = [super init];

    if (self) {
        self.currentFrame = [self prepareImage:frame];

        CGSize frameSize = CGSizeTransposed(frame.size);

        self.frameSize = cv::Size(
                static_cast<int>(frameSize.width),
                static_cast<int>(frameSize.height)
        );

        auto overlayMat = [overlay toCVMatrix];
        self.initialOverlay = [overlay toCVMatrix];

        cv::Mat::eye(3, 3, CV_32F);

        self.frameCount = 0;

        self.framesLock = [[NSLock alloc] init];
        self.queueLock = [[NSCondition alloc] init];

        self.warpQueue = [@[[[WarpResult alloc] initWithWarp:eyeWarp() andIndex:0]] mutableCopy];

        self.resultsCount = 0;
        self.resultCountLock = [[NSLock alloc] init];
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

    cv::Mat denoised = grayed;

//    cv::fastNlMeansDenoising(grayed, denoised, 15);

    return denoised;
}


- (NSInteger)addNewFrame:(UIImage *)frame {

    auto newFrame = [self prepareImage:frame];

    self.previousFrame = self.currentFrame;
    self.currentFrame = newFrame;
    self.frameCount++;

    auto from = self.previousFrame;
    auto to = newFrame;

    NSUInteger index = self.frameCount;


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^() {
        NSDate *methodStart = [NSDate date];

        cv::Mat warp = countWarp(from, to);

        [self countedWarp:warp withIndex:index];

        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
//
//        NSLog(@"counted %ld %f", index, executionTime);
    });

    [self.resultCountLock lock];

    NSUInteger resultsCount = self.resultsCount;

    [self.resultCountLock unlock];

    return index - resultsCount - 1;
}

- (void)countedWarp:(cv::Mat)warp withIndex:(NSUInteger)index {
    WarpResult *newResult = [[WarpResult alloc] initWithWarp:warp andIndex:index];

    NSUInteger insertIndex = 0;

    [self.queueLock lock];

    for (; insertIndex < self.warpQueue.count; insertIndex++) {
        WarpResult *warpResult = self.warpQueue[insertIndex];

       if (warpResult.index > index) {
           break;
       }
    }

    [self.warpQueue insertObject:newResult atIndex:insertIndex];

    [self.queueLock unlock];

    [self collapseQueue];

    [self.resultCountLock lock];

    self.resultsCount++;

    [self.resultCountLock unlock];
}

- (void)collapseQueue {
    [self.queueLock lock];

    if (self.warpQueue.count >= 2) {
        cv::Mat summarizedWarp = self.warpQueue.firstObject.warp;

        NSUInteger collapseIndex = 0;

        for (collapseIndex = 1; collapseIndex < self.warpQueue.count; ++collapseIndex) {
            if (self.warpQueue[collapseIndex].index != self.warpQueue[collapseIndex - 1].index + 1) {
                break;
            }

            auto collapsingWarp = self.warpQueue[collapseIndex];

//            summarizedWarp *= collapsingWarp.warp;
            summarizedWarp = collapsingWarp.warp * summarizedWarp;
        }

        if (collapseIndex > 1) {
            NSUInteger lastCollapsedIndex = self.warpQueue[collapseIndex - 1].index;

            [self.warpQueue removeObjectsInRange:NSMakeRange(0, collapseIndex)];

            WarpResult *collapsedResult = [[WarpResult alloc] initWithWarp:summarizedWarp andIndex:lastCollapsedIndex];

            [self.warpQueue insertObject:collapsedResult atIndex:0];
        }
    }

    [self.queueLock signal];

    [self.queueLock unlock];
}



- (UIImage *)warpedOverlay {


    [self.queueLock lock];

    cv::Mat warpMatrix = self.warpQueue.firstObject.warp;

    [self.queueLock unlock];

    auto overlayMat = self.initialOverlay;

    cv::Mat outputMat;

//    NSLog(@"test!!!");
//
//    printMat(warpMatrix);

    cv::warpPerspective(
            overlayMat,
            outputMat,
            warpMatrix,
            self.frameSize
            , cv::INTER_LINEAR + cv::WARP_INVERSE_MAP
    );

//    outputMat = self.currentFrame - self.previousFrame;
//
//    auto sum = cv::sum(outputMat);
//
//    NSMutableString *out = [NSMutableString stringWithString:@"sum: "];
//
//    outputMat *= 255;
//
//    for (int i = 0; i < sum.rows; ++i) {
//        [out appendFormat:@"%f, ", sum[i]];
//    }
//
//    NSLog(out);

    UIImage *warpedImage = [UIImage fromCVMatrix:outputMat];

    return warpedImage;
}

- (UIImage *)frame1 {
    return [UIImage fromCVMatrix:self.previousFrame];
}

- (UIImage *)frame2 {
    return [UIImage fromCVMatrix:self.currentFrame];
}

- (UIImage *)over {
    return [UIImage fromCVMatrix:self.initialOverlay];
}

@end
