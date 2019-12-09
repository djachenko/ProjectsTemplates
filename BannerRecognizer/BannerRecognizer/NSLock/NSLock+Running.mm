//
// Created by Igor Djachenko on 20/03/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

#import "NSLock+Running.h"


@implementation NSLock (Running)

- (void)run:(void (^)())lambda {
    [self lock];

    lambda();

    [self unlock];
}

@end