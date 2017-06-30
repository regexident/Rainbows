//
//  Rainbows.h
//  Rainbows
//
//  Created by Vincent Esche on 6/18/17.
//  Copyright © 2017 Vincent Esche. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#include <TargetConditionals.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#elif TARGET_OS_MAC

#import <AppKit/AppKit.h>

#endif

//! Project version number for Rainbows.
FOUNDATION_EXPORT double RainbowsVersionNumber;

//! Project version string for Rainbows.
FOUNDATION_EXPORT const unsigned char RainbowsVersionString[];

// In this header, you should import all the public headers of your
// framework using statements like #import <Rainbows/PublicHeader.h>

#import <Metal/Metal.h>
