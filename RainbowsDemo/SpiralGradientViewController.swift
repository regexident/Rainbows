//
//  SpiralGradientViewController.swift
//  RainbowsDemo
//
//  Created by Vincent Esche on 6/19/17.
//  Copyright © 2017 Vincent Esche. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import UIKit

import Rainbows

class SpiralGradientViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        guard let gradientView = self.view as? GradientView else {
            fatalError("No GradientView found.")
        }
        guard let gradientLayer = gradientView.layer as? GradientLayer else {
            fatalError("No GradientLayer found.")
        }

        gradientLayer.configuration = Configuration.spiral(
            center: CGPoint(x: 0.5, y: 0.5),
            angle: 0.0 * CGFloat.pi * 2.0,
            scale: 1.0
        )

        let gestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(SpiralGradientViewController.receivedGesture(_:))
        )
        gestureRecognizer.maximumNumberOfTouches = 2
        gradientView.addGestureRecognizer(gestureRecognizer)
    }

    @objc func receivedGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let gradientView = self.view as? GradientView else {
            fatalError("No GradientView found.")
        }
        let absoluteSize = gradientView.bounds.size

        let (centerPoint, anglePoint): (CGPoint, CGPoint)
        switch gestureRecognizer.numberOfTouches {
        case 1:
            let absoluteLocation = gestureRecognizer.location(in: gradientView)
            centerPoint = CGPoint(x: 0.5, y: 0.5)
            anglePoint = CGPoint(
                x: absoluteLocation.x / absoluteSize.width,
                y: (absoluteLocation.y / absoluteSize.height)
            )
        case 2:
            let absoluteCenterPoint = gestureRecognizer.location(ofTouch: 0, in: gradientView)
            centerPoint = CGPoint(
                x: absoluteCenterPoint.x / absoluteSize.width,
                y: (absoluteCenterPoint.y / absoluteSize.height)
            )
            let absoluteAnglePoint = gestureRecognizer.location(ofTouch: 1, in: gradientView)
            anglePoint = CGPoint(
                x: absoluteAnglePoint.x / absoluteSize.width,
                y: (absoluteAnglePoint.y / absoluteSize.height)
            )
        case _:
            return
        }

        let aspectRatio = absoluteSize.width / absoluteSize.height
        let x = anglePoint.x - centerPoint.x
        let y = (anglePoint.y - centerPoint.y) / aspectRatio
        let angle = atan2(-y, -x) + CGFloat.pi
        let scale = sqrt((x * x) + (y * y))

        gradientView.configuration = Configuration.spiral(
            center: centerPoint,
            angle: angle,
            scale: scale
        )
    }
}
