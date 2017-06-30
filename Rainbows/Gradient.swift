//
//  Gradient.swift
//  GradientLayer
//
//  Created by Vincent Esche on 6/18/17.
//  Copyright © 2017 Vincent Esche. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import CoreGraphics

/// Gradient Configuration
///
/// - axial: configuration for drawing an axial gradient
/// - radial: configuration for drawing a radial gradient
/// - sweep: configuration for drawing a sweel gradient
/// - spiral: configuration for drawing a spiral gradient
public enum Configuration {
    /// Configuration for drawing an axial gradient
    ///
    /// - Parameters:
    ///   - start: The end point of the gradient when drawn in the layer’s coordinate space.
    ///   - end: The start point of the gradient when drawn in the layer’s coordinate space.
    ///
    /// - Note:
    ///   The start and end points correspond to the first and last stops of the gradient.
    ///   The points are defined in the unit coordinate space and are then mapped to the
    ///   layer’s bounds rectangle when drawn.
    ///
    ///   Default values are (start: (0.0, 0.0), end: (1.0, 1.0).
    ///
    case axial(start: CGPoint, end: CGPoint)

    /// Configuration for drawing an radial gradient
    ///
    /// - Parameters:
    ///   - center: The center point of the gradient when drawn in the layer’s coordinate space.
    ///   - radius: The radius of the gradient when drawn in the layer’s coordinate space.
    ///
    /// - Note:
    ///   The start point corresponds to the first stop of the gradient. The point is defined
    ///   in the unit coordinate space and is then mapped to the layer’s bounds rectangle when
    ///   drawn. The radius is defined in the unit coordinate space, too.
    ///
    ///   Default values are (center: (0.0, 0.0), radius: 1.0).
    ///
    case radial(center: CGPoint, radius: CGFloat)

    /// Configuration for drawing an sweep gradient
    ///
    /// - Parameters:
    ///   - center: The center point of the gradient when drawn in the layer’s coordinate space.
    ///   - angle: The angle of the gradient when drawn in the layer’s coordinate space.
    ///
    /// - Note:
    ///   The start point corresponds to the first stop of the gradient. The point is defined
    ///   in the unit coordinate space and is then mapped to the layer’s bounds rectangle when
    ///   drawn. The angle is defined in radians (`1 turn == 2π`).
    ///
    ///   Default values are (center: (0.5, 0.5), radius: 1.0).
    ///
    case sweep(center: CGPoint, angle: CGFloat)

    /// Configuration for drawing an sweep gradient
    ///
    /// - Parameters:
    ///   - center: The center point of the gradient when drawn in the layer’s coordinate space.
    ///   - angle: The angle of the gradient when drawn in the layer’s coordinate space.
    ///   - scale: The scale of the gradient when drawn in the layer’s coordinate space.
    ///
    /// - Note:
    ///   The start point corresponds to the first stop of the gradient. The point is defined
    ///   in the unit coordinate space and is then mapped to the layer’s bounds rectangle when
    ///   drawn. The angle is defined in radians (`1 turn == 2π`).
    ///
    ///   Default values are (center: (0.5, 0.5), radius: 1.0).
    ///
    case spiral(center: CGPoint, angle: CGFloat, scale: CGFloat)
}

extension Configuration {
    internal static let `default`: Configuration = .axial(
        start: CGPoint(x: 0.0, y: 0.0),
        end: CGPoint(x: 1.0, y: 1.0)
    )
}

extension Configuration: Equatable {
    public static func == (lhs: Configuration, rhs: Configuration) -> Bool {
        switch (lhs, rhs) {
        case let (.axial(lhsS, lhsE), .axial(rhsS, rhsE)):
            return (lhsS == rhsS) && (lhsE == rhsE)
        case let (.radial(lhsC, lhsR), .radial(rhsC, rhsR)):
            return (lhsC == rhsC) && (lhsR == rhsR)
        case let (.sweep(lhsC, lhsA), .sweep(rhsC, rhsA)):
            return (lhsC == rhsC) && (lhsA == rhsA)
        case let (.spiral(lhsC, lhsA, lhsS), .spiral(rhsC, rhsA, rhsS)):
            return (lhsC == rhsC) && (lhsA == rhsA) && (lhsS == rhsS)
        case _: return false
        }
    }
}

/// Gradient
public struct Gradient {

    /// An array of `CGColor` objects defining the color of each gradient stop.
    public let colors: [CGColor]

    /// An array of `CGFloat` values defining the location of each gradient stop.
    public let locations: [CGFloat]


    /// Creates a `Gradient` object from the provided colors and locations.
    ///
    /// - Parameters:
    ///   - colors: colors of gradient stops
    ///   - locations: locations of gradient stops
    public init(colors: [CGColor], locations: [CGFloat]? = nil) {
        self.colors = colors
        if let locations = locations {
            assert(colors.count == locations.count, "Expected equal count of locations and colors.")
            self.locations = locations
        } else {
            let demoninator = CGFloat(colors.count - 1)
            self.locations = (0..<colors.count).map {
                1.0 * CGFloat($0) / demoninator
            }
        }
    }
}

extension Gradient {
    internal static let `default`: Gradient = {
        let colorSpace = CGColorSpace(name:CGColorSpace.genericRGBLinear)!

        var red: [CGFloat] = [1.0, 0.2157, 0.1412, 1.0]
        var orange: [CGFloat] = [1.0, 0.5882, 0.0, 1.0]
        var yellow: [CGFloat] = [1.0, 0.8039, 0.0039, 1.0]
        var green: [CGFloat] = [0.2667, 0.8588, 0.3686, 1.0]
        var blue: [CGFloat] = [0.3804, 0.6863, 0.9373, 1.0]
        var purple: [CGFloat] = [0.7302, 0.3783, 0.9414, 1.0]

        return Gradient(colors: [
            CGColor(colorSpace: colorSpace, components: &red)!,
            CGColor(colorSpace: colorSpace, components: &orange)!,
            CGColor(colorSpace: colorSpace, components: &yellow)!,
            CGColor(colorSpace: colorSpace, components: &green)!,
            CGColor(colorSpace: colorSpace, components: &blue)!,
            CGColor(colorSpace: colorSpace, components: &purple)!,
        ])
    }()
}

extension Gradient: Equatable {
    public static func == (lhs: Gradient, rhs: Gradient) -> Bool {
        return (lhs.colors == rhs.colors) && (lhs.locations == rhs.locations)
    }
}
