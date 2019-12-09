//
// Created by Igor Djachenko on 16/03/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

#import <opencv2/opencv.hpp>

#import "OverlaysManager.h"
#import "UIImage+CvConversion.h"
#import "ImageRecognizer.h"
#import "FrameWarper.h"
#import "NSLock+Running.h"

@interface ImageRecognizer()

- (cv::Mat)recognizeMatrix:(cv::Mat)sampleMatrix in:(cv::Mat)sourceMatrix;

@end

@interface NonRecognizedOverlay: NSObject

@property (nonatomic) cv::Mat sample;
@property (nonatomic) cv::Mat overlay;

@end

@implementation NonRecognizedOverlay

- (instancetype)initWithOverlay:(cv::Mat)overlay andSample:(cv::Mat)sample {
    self = [super init];

    if (self) {
        self.sample = sample;
        self.overlay = overlay;
    }

    return self;
}

@end

@interface RecognizedOverlay: NSObject

@property (nonatomic) cv::Mat sample;
@property (nonatomic) cv::Mat overlay;

@property (nonatomic) cv::Mat transform;

@end

@implementation RecognizedOverlay

- (instancetype)initWithUnrecognized:(NonRecognizedOverlay *)overlay andInitialTransform:(cv::Mat)transform {
    self = [super init];

    if (self) {
        self.sample = overlay.sample;
        self.overlay = overlay.overlay;

        self.transform = transform;
    }

    return self;
}

- (void)setOverlay:(cv::Mat)overlay {
    _overlay = overlay;
}


- (void)updateWithStep:(cv::Mat)step {
    self.transform *= step;
}

@end

@interface ReRecognizingOverlay: NSObject

@property (nonatomic) cv::Mat transform;

@property (nonatomic) RecognizedOverlay *overlayToUpdate;

@end

@implementation ReRecognizingOverlay

- (instancetype)initWithRecognized:(RecognizedOverlay *)overlay {
    self = [super init];

    if (self) {
        self.transform = cv::Mat::eye(3, 3, CV_32F);

        self.overlayToUpdate = overlay;
    }

    return self;
}

- (void)updateWithStep:(cv::Mat)step {
    self.transform *= step;
}

@end


@interface OverlaysManager()<FrameWarperDelegate>

@property (nonatomic) NSMutableArray<NonRecognizedOverlay *> *unrecognizedOverlays;
@property (nonatomic) NSMutableArray<RecognizedOverlay *> *recognizedOverlays;
@property (nonatomic) NSMutableArray<ReRecognizingOverlay *> *reRecognizingOverlays;

@property (nonatomic) NSLock *unrecognizedLock;
@property (nonatomic) NSLock *recognizedLock;
@property (nonatomic) NSLock *reRecognizedLock;


@property (nonatomic) ImageRecognizer *recognizer;
@property (nonatomic) FrameWarper *warper;

@property (nonatomic) NSUInteger frameCount;
@property (nonatomic) NSUInteger warpCount;

@property (nonatomic) NSLock *frameCountLock;
@property (nonatomic) NSLock *warpCountLock;

@end


@implementation OverlaysManager

- (instancetype)init {
    self = [super init];

    if (self) {
        self.unrecognizedOverlays = [NSMutableArray array];
        self.recognizedOverlays = [NSMutableArray array];
        self.reRecognizingOverlays = [NSMutableArray array];

        self.unrecognizedLock = [[NSLock alloc] init];
        self.recognizedLock = [[NSLock alloc] init];
        self.reRecognizedLock = [[NSLock alloc] init];

        self.recognizer = [[ImageRecognizer alloc] init];
        self.warper = [[FrameWarper alloc] init];


        self.frameCount = 0;
        self.warpCount = 0;

        self.frameCountLock = [[NSLock alloc] init];
        self.warpCountLock = [[NSLock alloc] init];
    }

    return self;
}

+ (NSUInteger)refreshRate {
    return 20;
}

+ (NSUInteger)skipFrameRate {
    return 2;
}

- (void)registerOverlay:(UIImage *)overlay withSample:(UIImage *)sample {
    auto overlayMat = [overlay toCVMatrix];
    auto sampleMat = [sample toCVMatrix];

    NonRecognizedOverlay *overTemplate = [[NonRecognizedOverlay alloc] initWithOverlay:overlayMat andSample:sampleMat];

    [self.unrecognizedLock run:^() {
        [self.unrecognizedOverlays addObject:overTemplate];
    }];
}

- (void)recognize:(UIImage *)frame {
    auto frameMat = [frame toCVMatrix];

    for (NonRecognizedOverlay *overlay in self.unrecognizedOverlays) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^() {

            auto matrix = [self.recognizer recognizeMatrix:overlay.sample in:frameMat];

            if (!matrix.empty()) {
                RecognizedOverlay *recognizedOverlay = [[RecognizedOverlay alloc] initWithUnrecognized:overlay andInitialTransform:matrix];


                [self.recognizedLock run:^() {
                    [self.recognizedOverlays addObject:recognizedOverlay];
                }];

                [self.unrecognizedLock run:^() {
                    [self.unrecognizedOverlays removeObject:overlay];
                }];
            }
        });
    }
}

- (BOOL)updateRequired {
    return self.recognizedOverlays.count > 0;
}

- (NSUInteger)updateFrame:(UIImage *)frame {
    self.frameCount++;

    NSUInteger frameCount = self.frameCount;


    [self.recognizedLock lock];

    BOOL updateRequired = self.updateRequired;

    [self.recognizedLock unlock];


    if (updateRequired) {
        if (frameCount % OverlaysManager.skipFrameRate == 0) {
            [self.warper registerFrame:frame];
        }

        if (frameCount % OverlaysManager.refreshRate == 0) {
            [self refresh:[frame toCVMatrix]];
        }
    }


    [self.warpCountLock lock];
    NSUInteger result = frameCount - self.warpCount;
    [self.warpCountLock unlock];

    return result;
}

- (void)updateWithStep:(cv::Mat)warp {
    [self.recognizedLock run:^() {
        for (RecognizedOverlay *overlay in self.recognizedOverlays) {
            [overlay updateWithStep:warp];
        }
    }];

    [self.reRecognizedLock run:^() {
        for (ReRecognizingOverlay *overlay in self.reRecognizingOverlays) {
            [overlay updateWithStep:warp];
        }
    }];
}

- (void)refresh:(cv::Mat)frame {
    [self.recognizedLock run:^() {
        for (RecognizedOverlay *overlay in self.recognizedOverlays) {
            ReRecognizingOverlay *transformCollector = [[ReRecognizingOverlay alloc] initWithRecognized:overlay];

            [self.reRecognizedLock run:^() {
                [self.reRecognizingOverlays addObject:transformCollector];
            }];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^() {
                auto newInitialTransform = [self.recognizer recognizeMatrix:overlay.sample in:frame];

                if (!newInitialTransform.empty()) {
                    [self.recognizedLock run:^() {
                        transformCollector.overlayToUpdate.transform = transformCollector.transform * newInitialTransform;
                    }];
                } else {
                    RecognizedOverlay *disappearedOverlay = transformCollector.overlayToUpdate;

                    [self.recognizedLock run:^() {
                        [self.recognizedOverlays removeObject:disappearedOverlay];

                        if (self.recognizedOverlays.count == 0) {
                            self.warper = nil;
                        }
                    }];

                    NonRecognizedOverlay *unrecognizedOverlay = [[NonRecognizedOverlay alloc] initWithOverlay:disappearedOverlay.overlay andSample:disappearedOverlay.sample];

                    [self.unrecognizedLock run:^() {
                        [self.unrecognizedOverlays addObject:unrecognizedOverlay];
                    }];
                }

                [self.reRecognizedLock run:^() {
                    [self.reRecognizingOverlays removeObject:transformCollector];
                }];
            });
        }
    }];
}

- (UIImage *)mergedOverlay {
    [self.recognizedLock lock];

    if (self.recognizedOverlays.count == 0) {
        [self.recognizedLock unlock];

        return nil;
    }

    RecognizedOverlay *overlay = self.recognizedOverlays.firstObject;

    auto resultingOverlay = overlay.transform * overlay.overlay;

    [self.recognizedLock unlock];

    UIImage *resultingImage = [UIImage fromCVMatrix:resultingOverlay];

    return resultingImage;
}

- (void)countedWarp:(cv::Mat)warp {
    [self updateWithStep:warp];

    [self.warpCountLock run:^() {
        self.warpCount++;
    }];
}


@end