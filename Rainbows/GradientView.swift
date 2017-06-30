//
//  GradientView.swift
//  Rainbows
//
//  Created by Vincent Esche on 6/19/17.
//  Copyright © 2017 Vincent Esche. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import UIKit
import Metal

#if os(iOS)
    import UIKit

    /// A view that draws a color gradient over its background color,
    /// filling the shape of the view (including rounded corners).
    public class GradientView: UIView {

        /// Layer's gradient.
        public var gradient: Gradient {
            get {
                return (self.layer as! GradientLayer).gradient
            }
            set {
                (self.layer as! GradientLayer).gradient = newValue
            }
        }

        /// Layer's gradient drawing configuration.
        public var configuration: Configuration {
            get {
                return (self.layer as! GradientLayer).configuration
            }
            set {
                (self.layer as! GradientLayer).configuration = newValue
            }
        }

        public override class var layerClass: AnyClass {
            return GradientLayer.self
        }
    }
#endif

