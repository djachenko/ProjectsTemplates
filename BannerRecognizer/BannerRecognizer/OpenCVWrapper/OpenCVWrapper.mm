//
// Created by Igor Djachenko on 14/02/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/ios.h>
#import "OpenCVWrapper.h"


@implementation OpenCVWrapper

- (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

@end






