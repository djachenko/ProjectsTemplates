//
//  ViewController.swift
//  BannerRecognizer
//
//  Created by Igor Djachenko on 14/02/2018.
//  Copyright © 2018 Igor Djachenko. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self

        sceneView.showsStatistics = true

        let scene = SCNScene()

        sceneView.scene = scene
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()

        sceneView.session.run(configuration)
        sceneView.session.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    var savedImage: UIImage?// = UIImage(named: "mockInput")

    @IBOutlet private weak var overlaysView: UIView!
    @IBOutlet private weak var testInput: UIImageView!

    var imageWarper: ImageWarper!
    weak var overlayImageView: UIImageView!

    @IBOutlet private weak var cameraInput: UIImageView!
    @IBOutlet private weak var mockInput: UIImageView!

    @IBOutlet private weak var cameraInputRecognized: UIImageView!
    @IBOutlet private weak var mockInputRecognized: UIImageView!

    private var count: Int = 0
    private var imageIndex: Int = 0

    private var warpCount = 15

    private static var addFrameStep = 3
    private static let overlayUpdateStep = 10

    private let manager = OverlaysManager()


    var previousFrameTime: Date!
}

func measure(name: String = "", code: ()->Void) {
    let methodStart = Date()

    code()

    let methodFinish = Date()

    let executionTime = methodFinish.timeIntervalSince(methodStart)

    print("Measured \(name): \(executionTime)")
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let image = UIImage.from(buffer: frame.capturedImage)

        savedImage = image


        manager.updateFrame(image);

        if count % ViewController.overlayUpdateStep == 0 {
            if let newOverlay = manager.mergedOverlay() {
                overlayImageView.image = newOverlay
            }
        }

        count += 1;

    }

    func shit() {

        let currentFrameTime = Date()

        if previousFrameTime != nil {
            let executionTime = currentFrameTime.timeIntervalSince(previousFrameTime)

            let precision = 100.0

            let rounded = Double(round(precision * executionTime) / precision)

//            print("time between frames: \(rounded)")
        }

        previousFrameTime = currentFrameTime

        let image = UIImage()


        savedImage = image

        if let imageWarper = imageWarper {
            if count % ViewController.addFrameStep == 0 {
                var handicap = 0

//                measure(name: "addNewFrame") {
                handicap = imageWarper.addNewFrame(savedImage)
//                }

                if handicap > 0 {
                    ViewController.addFrameStep += 1
                } else if handicap <= 0 {
                    ViewController.addFrameStep -= 3

                    if ViewController.addFrameStep < 1 {
                        ViewController.addFrameStep = 1
                    }
                }

                print("frame step \(ViewController.addFrameStep) \(handicap)")
            }

            if false || count % ViewController.overlayUpdateStep == 0 {

                var newOverlay: UIImage!

                measure(name: "overlay") {
                    newOverlay = imageWarper.warpedOverlay()
                }

                overlayImageView.image = newOverlay

//                mockInputRecognized.image = newOverlay;
            }
        }

    }
}

extension ViewController {
    @IBAction private func startAnalysis() {
        guard let savedImage = savedImage else {
            return
        }

        let sample = UIImage(named: "sample")
        let replacement = UIImage(named: "replacement")

        manager.registerOverlay(replacement, withSample: sample)

        manager.recognize(savedImage)

        return

        let imageRecognizer = ImageRecognizer()

        let overlay = imageRecognizer.overlay(forFrame: savedImage, withSample: sample!, andReplacement: replacement!)
//
        imageWarper = ImageWarper(firstFrame: savedImage, andOverlay: overlay)!
//        imageWarper = ImageWarper(firstFrame: savedImage, andOverlay: sample)!


        let imageView = UIImageView(image: overlay)

        imageView.contentMode = .scaleAspectFill

        imageView.frame = overlaysView.bounds

        overlaysView.addSubview(imageView)
        overlayImageView = imageView
    }

    @IBAction private func clearOverlays() {
        overlaysView.subviews.forEach { subview in
            subview.removeFromSuperview()

            testInput.image = nil
            imageWarper = nil
        }
    }
}
