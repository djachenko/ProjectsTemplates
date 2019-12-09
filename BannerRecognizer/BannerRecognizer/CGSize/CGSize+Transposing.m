//
// Created by Igor Djachenko on 27/02/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//


#import "CGSize+Transposing.h"

CGSize CGSizeTransposed(CGSize inner) {
    return CGSizeMake(inner.height, inner.width);
}
