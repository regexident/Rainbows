//
//  GradientRenderer.swift
//  GradientLayer
//
//  Created by Vincent Esche on 6/18/17.
//  Copyright © 2017 Vincent Esche. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import QuartzCore
import Metal

import Rainbows_Private

typealias ShaderStops = uint1
typealias ShaderColor = float4
typealias ShaderVector = float2
typealias ShaderPoint = float2
typealias ShaderScalar = float1
typealias ShaderLocation = float1

/// Gradient renderer
public class GradientRenderer {
    private static let maxStopsCount: Int = 32

    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let axialUniformsBuffer: MTLBuffer
    private let radialUniformsBuffer: MTLBuffer
    private let sweepUniformsBuffer: MTLBuffer
    private let spiralUniformsBuffer: MTLBuffer
    private let colorsBuffer: MTLBuffer
    private let locationsBuffer: MTLBuffer

    private var pipelineState: MTLComputePipelineState!
    private var previousConfiguration: Configuration?

    private lazy var library: MTLLibrary = {
        return GradientRenderer.library(device: self.device)
    }()

    private lazy var axialFunction: MTLFunction = {
        guard let function = self.library.makeFunction(name: "axial") else {
            fatalError("Could not find kernel function!")
        }
        return function
    }()

    private lazy var radialFunction: MTLFunction = {
        guard let function = self.library.makeFunction(name: "radial") else {
            fatalError("Could not find kernel function!")
        }
        return function
    }()

    private lazy var sweepFunction: MTLFunction = {
        guard let function = self.library.makeFunction(name: "sweep") else {
            fatalError("Could not find kernel function!")
        }
        return function
    }()

    private lazy var spiralFunction: MTLFunction = {
        guard let function = self.library.makeFunction(name: "spiral") else {
            fatalError("Could not find kernel function!")
        }
        return function
    }()

    /// Creates a gradient renderer.
    ///
    /// - Parameters:
    ///   - device: the Metal device to render on
    public init(
        device: MTLDevice = MTLCreateSystemDefaultDevice()!
    ) {
        self.device = device

        self.commandQueue = self.device.makeCommandQueue()!
        self.commandQueue.label = "Main command queue"

        self.axialUniformsBuffer = device.makeBuffer(
            length: MemoryLayout<AxialUniforms>.stride,
            options: [.storageModeShared]
        )!
        self.radialUniformsBuffer = device.makeBuffer(
            length: MemoryLayout<RadialUniforms>.stride,
            options: [.storageModeShared]
        )!
        self.sweepUniformsBuffer = device.makeBuffer(
            length: MemoryLayout<SweepUniforms>.stride,
            options: [.storageModeShared]
        )!
        self.spiralUniformsBuffer = device.makeBuffer(
            length: MemoryLayout<SpiralUniforms>.stride,
            options: [.storageModeShared]
        )!

        self.colorsBuffer = device.makeBuffer(
            length: MemoryLayout<ShaderColor>.stride * GradientRenderer.maxStopsCount,
            options: [.storageModeShared]
        )!
        self.locationsBuffer = device.makeBuffer(
            length: MemoryLayout<ShaderLocation>.stride * GradientRenderer.maxStopsCount,
            options: [.storageModeShared]
        )!
    }

    /// Renders gradient into drawable according to provided configuration
    ///
    /// - Parameters:
    ///   - gradient: the gradient to render
    ///   - configuration: the gradient's drawing configuration
    ///   - drawable: the drawable to render into
    public func render(
        gradient: Gradient,
        as configuration: Configuration,
        in drawable: CAMetalDrawable
    ) {
        assert(gradient.colors.count <= GradientRenderer.maxStopsCount)
        assert(gradient.locations.count <= GradientRenderer.maxStopsCount)
        assert(gradient.colors.count == gradient.locations.count)

        guard let commandBuffer = self.commandQueue.makeCommandBuffer() else {
            NSLog("Aborting: Could not make command buffer.")
            return
        }

        let texture = drawable.texture

        let pipelineState = self.updatePipelineState(for: configuration)

        let uniformsBuffer = self.updateUniformsBuffer(for: gradient, as: configuration)
        let colorsBuffer = self.updateColorsBuffer(for: gradient, device: device)
        let locationsBuffer = self.updateLocationsBuffer(for: gradient, device: device)

        let threadGroupSize = MTLSize(width: 16, height: 16, depth: 1)
        let threadGroups: MTLSize = MTLSize(
            width: (texture.width / threadGroupSize.width) + 1,
            height: (texture.height / threadGroupSize.height) + 1,
            depth: 1
        )

        guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
            NSLog("Aborting: Could not make command encoder.")
            return
        }

        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setBuffer(uniformsBuffer, offset: 0, index: 0)
        commandEncoder.setBuffer(colorsBuffer, offset: 0, index: 1)
        commandEncoder.setBuffer(locationsBuffer, offset: 0, index: 2)
        commandEncoder.setTexture(texture, index: 0)
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        commandEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func updatePipelineState(for configuration: Configuration) -> MTLComputePipelineState {
        if case let (state?, prevConf?) = (self.pipelineState, self.previousConfiguration) {
            if prevConf.hasSameKind(as: configuration) {
                return state
            }
        }

        let function: MTLFunction
        switch configuration {
        case .axial(_, _): function = self.axialFunction
        case .radial(_, _): function = self.radialFunction
        case .sweep(_, _): function = self.sweepFunction
        case .spiral(_, _, _): function = self.spiralFunction
        }
        let pipelineState = try! self.device.makeComputePipelineState(function: function)
        self.pipelineState = pipelineState
        return pipelineState
    }

    private static func library(device: MTLDevice) -> MTLLibrary {
        let bundle = Bundle(for: self)
        let library: MTLLibrary
        do {
            guard let path = bundle.path(forResource: "default", ofType: "metallib") else {
                fatalError("Could not load library with name 'default.metallib'")
            }
            library = try device.makeLibrary(filepath: path)
        } catch {
            fatalError("Could not load default library from bundle '\(String(describing: bundle.bundleIdentifier))'")
        }
        return library
    }

    private func updateUniformsBuffer(
        for gradient: Gradient,
        as configuration: Configuration
    ) -> MTLBuffer {
        switch configuration {
        case let .axial(start, end):
            typealias Uniforms = AxialUniforms
            let uniforms = Uniforms(
                start: shaderPoint(start),
                end: shaderPoint(end),
                stops: shaderStops(gradient.colors.count)
            )
            let buffer = self.axialUniformsBuffer
            let pointer = buffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
            pointer.pointee = uniforms
            return buffer
        case let .radial(center, radius):
            typealias Uniforms = RadialUniforms
            let uniforms = Uniforms(
                center: shaderPoint(center),
                radius: shaderScalar(radius),
                stops: shaderStops(gradient.colors.count)
            )
            let buffer = self.radialUniformsBuffer
            let pointer = buffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
            pointer.pointee = uniforms
            return buffer
        case let .sweep(center, angle):
            typealias Uniforms = SweepUniforms
            let uniforms = Uniforms(
                center: shaderPoint(center),
                angle: shaderScalar(angle),
                stops: shaderStops(gradient.colors.count)
            )
            let buffer = self.sweepUniformsBuffer
            let pointer = buffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
            pointer.pointee = uniforms
            return buffer
        case let .spiral(center, angle, scale):
            typealias Uniforms = SpiralUniforms
            let uniforms = Uniforms(
                center: shaderPoint(center),
                angle: shaderScalar(angle),
                scale: shaderScalar(scale),
                stops: shaderStops(gradient.colors.count)
            )
            let buffer = self.spiralUniformsBuffer
            let pointer = buffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
            pointer.pointee = uniforms
            return buffer
        }
    }

    private func updateColorsBuffer(
        for gradient: Gradient,
        device: MTLDevice
    ) -> MTLBuffer {
        let colorCount = gradient.colors.count
        assert(colorCount <= GradientRenderer.maxStopsCount)
        let buffer = self.colorsBuffer
        let bufferLength = buffer.length
        let rawPointer = buffer.contents()
        let typedPointer = rawPointer.bindMemory(
            to: ShaderColor.self,
            capacity: bufferLength / MemoryLayout<ShaderColor>.stride
        )
        let typedBufferPointer = UnsafeMutableBufferPointer(start: typedPointer, count: colorCount)
        for (index, color) in gradient.colors.enumerated() {
            typedBufferPointer[index] = shaderColor(color)
        }
        return self.colorsBuffer
    }

    private func updateLocationsBuffer(
        for gradient: Gradient,
        device: MTLDevice
    ) -> MTLBuffer {
        let locationCount = gradient.locations.count
        assert(locationCount <= GradientRenderer.maxStopsCount)
        let buffer = self.locationsBuffer
        let bufferLength = buffer.length
        let rawPointer = buffer.contents()
        let typedPointer = rawPointer.bindMemory(
            to: ShaderLocation.self,
            capacity: bufferLength / MemoryLayout<ShaderLocation>.stride
        )
        let typedBufferPointer = UnsafeMutableBufferPointer(start: typedPointer, count: locationCount)
        for (index, location) in gradient.locations.enumerated() {
            typedBufferPointer[index] = shaderLocation(location)
        }
        return self.locationsBuffer
    }
}

private func shaderColor(_ cgColor: CGColor) -> ShaderColor {
    let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear)!
    guard let color = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil) else {
        fatalError("Could not convert color to linear RGB color space.")
    }
    let components = color.components!
    return .init(
        shaderScalar(components[0]),
        shaderScalar(components[1]),
        shaderScalar(components[2]),
        shaderScalar(components[3])
    )
}

private func shaderPoint(_ cgPoint: CGPoint) -> ShaderPoint {
    .init(
        shaderScalar(cgPoint.x),
        shaderScalar(cgPoint.y)
    )
}

private func shaderScalar(_ cgFloat: CGFloat) -> ShaderScalar {
    .init(cgFloat)
}

private func shaderLocation(_ cgFloat: CGFloat) -> ShaderLocation {
    .init(cgFloat)
}

private func shaderStops(_ int: Int) -> ShaderStops {
    .init(UInt32(clamping: int))
}
