//
//  ShaderTypes.h
//  Rainbows
//
//  Created by Vincent Esche on 6/18/17.
//  Copyright © 2017 Vincent Esche. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#ifndef shared_h
#define shared_h

#ifdef __METAL_VERSION__

#include <metal_stdlib>
using namespace metal;

#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t

typedef float float1;

#else

#import <simd/simd.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

typedef simd_uint1 uint1;
typedef simd_float4 float4;
typedef simd_float3 float3;
typedef simd_float2 float2;
typedef simd_float1 float1;

#endif

typedef struct {
    float2 start;
    float2 end;
    uint32_t stops;
} AxialUniforms;

typedef struct {
    float2 center;
    float1 radius;
    uint32_t stops;
} RadialUniforms;

typedef struct {
    float2 center;
    float1 angle;
    float1 scale;
    uint32_t stops;
} SpiralUniforms;

typedef struct {
    float2 center;
    float1 angle;
    uint32_t stops;
} SweepUniforms;

#ifdef __METAL_VERSION__

float4 interpolate_color(
    constant float4 *colors,
    constant float1 *locations,
    uint count,
    float1 location
);

float2 fix_aspect_ratio(float2 point, float1 aspect_ratio);

#endif

#endif /* shared_h */
