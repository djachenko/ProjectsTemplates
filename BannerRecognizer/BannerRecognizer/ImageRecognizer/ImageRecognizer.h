//
// Created by Igor Djachenko on 15/02/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageRecognizer : NSObject

//- (cv::Mat)recognizeMatrix:(cv::Mat)sampleMatrix in:(cv::Mat)sourceMatrix;

- (UIImage *)overlayForFrame:(UIImage *)frameImage withSample:(UIImage *)sample andReplacement:(UIImage *)replacement;

@end