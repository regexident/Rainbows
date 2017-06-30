//
//  AxialGradientViewController.swift
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

class AxialGradientViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        guard let gradientView = self.view as? GradientView else {
            fatalError("No GradientView found.")
        }
        guard let gradientLayer = gradientView.layer as? GradientLayer else {
            fatalError("No GradientLayer found.")
        }

        gradientLayer.configuration = Configuration.axial(
            start: CGPoint(x: 0.0, y: 0.0),
            end: CGPoint(x: 1.0, y: 1.0)
        )

        let gestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(AxialGradientViewController.receivedGesture(_:))
        )
        gestureRecognizer.maximumNumberOfTouches = 2
        gradientView.addGestureRecognizer(gestureRecognizer)
    }

    @objc func receivedGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let gradientView = self.view as? GradientView else {
            fatalError("No GradientView found.")
        }
        let absoluteSize = gradientView.bounds.size

        let (startPoint, endPoint): (CGPoint, CGPoint)
        switch gestureRecognizer.numberOfTouches {
        case 1:
            let absoluteLocation = gestureRecognizer.location(in: gradientView)
            startPoint = CGPoint(
                x: absoluteLocation.x / absoluteSize.width,
                y: absoluteLocation.y / absoluteSize.height
            )
            endPoint = CGPoint(
                x: 1.0 - startPoint.x,
                y: 1.0 - startPoint.y
            )
        case 2:
            let absoluteStartPoint = gestureRecognizer.location(ofTouch: 0, in: gradientView)
            startPoint = CGPoint(
                x: absoluteStartPoint.x / absoluteSize.width,
                y: absoluteStartPoint.y / absoluteSize.height
            )
            let absoluteEndPoint = gestureRecognizer.location(ofTouch: 1, in: gradientView)
            endPoint = CGPoint(
                x: absoluteEndPoint.x / absoluteSize.width,
                y: absoluteEndPoint.y / absoluteSize.height
            )
        case _:
            return
        }

        gradientView.configuration = Configuration.axial(
            start: startPoint,
            end: endPoint
        )
    }
}
