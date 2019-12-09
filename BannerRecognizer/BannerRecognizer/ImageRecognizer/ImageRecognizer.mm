//
// Created by Igor Djachenko on 15/02/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

#import "opencv2/opencv.hpp"
#import "opencv2/ios.h"
#import "UIImage+CvConversion.h"
#import "ImageRecognizer.h"
#import "CGSize+Transposing.h"


@implementation ImageRecognizer

- (cv::Mat)prepareImage:(UIImage *)image {
    auto imageMat = [image toCVMatrix];

    cv::Mat rotated;

    cv::rotate(imageMat, rotated, cv::ROTATE_90_CLOCKWISE);

    return rotated;
}

- (cv::Mat)recognizeImage:(UIImage *)sample in:(UIImage *)frame {
    auto sampleMatrix = [sample toCVMatrix];
    auto sourceMatrix = [self prepareImage:frame];

    auto transformMatrix = [self recognizeMatrix:sampleMatrix in:sourceMatrix];

    return transformMatrix;
}

- (cv::Mat)recognizeMatrix:(cv::Mat)sampleMatrix in:(cv::Mat)sourceMatrix {
    auto brisk = cv::BRISK::create();

    std::vector<cv::KeyPoint> sourceKeypoints;
    std::vector<cv::KeyPoint> sampleKeypoints;
    cv::Mat sourceDescriptors;
    cv::Mat sampleDescriptors;

    brisk->detectAndCompute(sourceMatrix, cv::noArray(), sourceKeypoints, sourceDescriptors);
    brisk->detectAndCompute(sampleMatrix, cv::noArray(), sampleKeypoints, sampleDescriptors);

    auto matcher = cv::BFMatcher::create(cv::NORM_HAMMING);
    std::vector<cv::DMatch> existingMatches;

    matcher->match(sampleDescriptors, sourceDescriptors, existingMatches);

    std::vector<cv::Point2f> sampleCoordinates;
    std::vector<cv::Point2f> sourceCoordinates;

    NSLog(@"matches count: %ld", existingMatches.size());

    for (auto match : existingMatches) {
        auto samplePoint = sampleKeypoints[match.queryIdx];
        auto sourcePoint = sourceKeypoints[match.trainIdx];

        sampleCoordinates.push_back(samplePoint.pt);
        sourceCoordinates.push_back(sourcePoint.pt);
    }

    auto homographyMatrix = cv::findHomography(sampleCoordinates, sourceCoordinates, CV_RANSAC);

    return homographyMatrix;
}



- (UIImage *)overlayFrom:(UIImage *)image withSize:(CGSize)cgSize andTransform:(cv::Mat)matrix {
    auto imageMatrix = [image toCVMatrix];

    cv::Size size(
            static_cast<int>(cgSize.width),
            static_cast<int>(cgSize.height)
    );

    cv::Mat transformedMatrix = imageMatrix;

    cv::warpPerspective(imageMatrix, transformedMatrix, matrix, size);

    UIImage *overlayImage = [UIImage fromCVMatrix:transformedMatrix];

    return overlayImage;
}

- (UIImage *)overlayForFrame:(UIImage *)frameImage withSample:(UIImage *)sample andReplacement:(UIImage *)replacement {
    auto transform = [self recognizeImage:sample in:frameImage];

    UIImage *overlay = [self overlayFrom:replacement withSize:CGSizeTransposed(frameImage.size) andTransform:transform];

    return overlay;
}

@end