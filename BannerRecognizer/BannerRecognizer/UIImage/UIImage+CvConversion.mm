//
// Created by Igor Djachenko on 22/02/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

#import <opencv2/ios.h>
#import "UIImage+CvConversion.h"


@implementation UIImage (CvConversion)

+ (UIImage *)fromCVMatrix:(cv::Mat)matrix {
    return MatToUIImage(matrix);
}

- (cv::Mat)toCVMatrix {
    cv::Mat cvImageMatrix;

    UIImageToMat(self, cvImageMatrix, true);

    return cvImageMatrix;
}

@end