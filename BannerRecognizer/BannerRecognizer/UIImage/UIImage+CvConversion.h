//
// Created by Igor Djachenko on 22/02/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIImage (CvConversion)

+ (UIImage *)fromCVMatrix:(cv::Mat)matrix;
- (cv::Mat)toCVMatrix;

@end