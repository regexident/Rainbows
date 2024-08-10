//
//  shared.metal
//  Rainbows
//
//  Created by Vincent Esche on 6/19/17.
//  Copyright © 2017 Vincent Esche. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#include <metal_stdlib>
using namespace metal;

#include "shared.h"

float4 interpolate_color(
	constant float4 *colors,
	constant float *locations,
	uint count,
    float location
) {
    uint lower = 0;
    uint upper;
    for (upper = 0; upper < count; upper++) {
        if (locations[upper] > location) {
            break;
        }
        lower = upper;
    }
    float numerator = location - locations[lower];
    float denominator = locations[upper] - locations[lower];
    float fraction = (denominator != 0.0) ? saturate(numerator / denominator) : 0.0;
    return mix(colors[lower], colors[upper], fraction);
}

float2 fix_aspect_ratio(float2 point, float aspect_ratio) {
    point -= float2(0.5, 0.5);
    point /= float2(1.0, aspect_ratio);
    point += float2(0.5, 0.5);
    return point;
}
