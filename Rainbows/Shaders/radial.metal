//
//  radial.metal
//  Rainbows
//
//  Created by Vincent Esche on 6/18/17.
//  Copyright © 2017 Vincent Esche. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#include <metal_stdlib>
using namespace metal;

#include "shared.h"

kernel void radial(
    constant RadialUniforms *uniforms [[buffer(0)]],
    constant float4 *colors [[buffer(1)]],
    constant float *locations [[buffer(2)]],
    texture2d<float, access::write> texture [[ texture(0) ]],
    uint2 global_id [[ thread_position_in_grid ]]
) {
    // Make sure we're inside the output texture's bounds
    // (Workgroups don't necessarily have to line-up with texture dimensions):
    if (global_id.x >= texture.get_width() || global_id.y >= texture.get_height()) {
        return;
    }

    // Get output's dimensions:
    const float2 dimensions = float2(texture.get_width(), texture.get_height());

    // Get output's aspect ratio:
    const float aspect_ratio = dimensions.x / dimensions.y;

    // Get normalized 2D coordinate of output texture pixel:
    const float2 coordinate = fix_aspect_ratio(float2(global_id) / dimensions, aspect_ratio);
    const float2 center = fix_aspect_ratio(uniforms->center, aspect_ratio);
    const float radius = uniforms->radius;

    const float2 direction = coordinate - center;
    const float linearLocation = saturate(length(direction) / radius);
    const float sigmoidalLocation = smoothstep(0.0, 1.0, linearLocation);
    const float location = sigmoidalLocation;

    const float4 result_color = interpolate_color(colors, locations, uniforms->stops, location);

    texture.write(result_color, global_id);
}
