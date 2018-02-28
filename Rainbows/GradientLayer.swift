//
//  GradientLayer.swift
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

/// A layer that draws a color gradient over its background color,
/// filling the shape of the layer (including rounded corners).
public class GradientLayer: CAMetalLayer {

    private enum Keys: String {
        case gradient, configuration
    }

    /// Layer's gradient.
    public var gradient: Gradient = .default {
        didSet {
            self.setNeedsDisplay()
        }
    }

    /// Layer's gradient drawing configuration.
    public var configuration: Configuration = .default {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public override var bounds: CGRect {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public override var device: MTLDevice? {
        didSet {
            if let device = self.device {
                self.renderer = GradientRenderer(device: device)
            } else {
                self.renderer = nil
            }
        }
    }

    private var renderer: GradientRenderer?

    public override init() {
        super.init()

        self.commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.commonInit()
    }

    private func commonInit() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            NSLog("Metal not supported.")

            let colorSpace = CGColorSpace(name:CGColorSpace.genericRGBLinear)!
            var magenta: [CGFloat] = [1.0, 0.0, 1.0, 1.0]
            self.backgroundColor = CGColor(colorSpace: colorSpace, components: &magenta)!

            return
        }
        self.device = device
        self.pixelFormat = .bgra8Unorm
        self.framebufferOnly = false
    }

    public override func display() {
        super.display()

        guard let renderer = self.renderer else {
            return
        }
        autoreleasepool {
            guard let drawable = self.nextDrawable() else {
                return
            }
            renderer.render(
                gradient: self.gradient,
                as: self.configuration,
                in: drawable
            )
        }
    }
}
