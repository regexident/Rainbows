//
//  RadialGradientViewController.swift
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

class RadialGradientViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        guard let gradientView = self.view as? GradientView else {
            fatalError("No GradientView found.")
        }
        guard let gradientLayer = gradientView.layer as? GradientLayer else {
            fatalError("No GradientLayer found.")
        }

        gradientLayer.configuration = Configuration.radial(
            center: CGPoint(x: 0.5, y: 0.5),
            radius: 1.0
        )
        
        let gestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(RadialGradientViewController.receivedGesture(_:))
        )
        gestureRecognizer.maximumNumberOfTouches = 2
        gradientView.addGestureRecognizer(gestureRecognizer)
    }

    @objc func receivedGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let gradientView = self.view as? GradientView else {
            fatalError("No GradientView found.")
        }
        let absoluteSize = gradientView.bounds.size

        let (centerPoint, perimeterPoint): (CGPoint, CGPoint)
        switch gestureRecognizer.numberOfTouches {
        case 1:
            let absoluteLocation = gestureRecognizer.location(in: gradientView)
            centerPoint = CGPoint(x: 0.5, y: 0.5)
            perimeterPoint = CGPoint(
                x: absoluteLocation.x / absoluteSize.width,
                y: absoluteLocation.y / absoluteSize.height
            )
        case 2:
            let absoluteCenterPoint = gestureRecognizer.location(ofTouch: 0, in: gradientView)
            centerPoint = CGPoint(
                x: absoluteCenterPoint.x / absoluteSize.width,
                y: absoluteCenterPoint.y / absoluteSize.height
            )
            let absolutePerimeterPoint = gestureRecognizer.location(ofTouch: 1, in: gradientView)
            perimeterPoint = CGPoint(
                x: absolutePerimeterPoint.x / absoluteSize.width,
                y: absolutePerimeterPoint.y / absoluteSize.height
            )
        case _:
            return
        }

        let aspectRatio = absoluteSize.width / absoluteSize.height
        let x = centerPoint.x - perimeterPoint.x
        let y = (centerPoint.y - perimeterPoint.y) / aspectRatio
        let radius = sqrt((x * x) + (y * y))

        gradientView.configuration = Configuration.radial(
            center: centerPoint,
            radius: radius
        )
    }
}

