//
//  ViewController.swift
//  ARKitBannerRecognizer
//
//  Created by Igor Djachenko on 26/03/2018.
//  Copyright © 2018 Igor Djachenko. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!

    private var activeImageNodes = [String: SCNNode]()
    private var nodesToRemove = [String: SCNNode]()

    private static let widths = [0.7, 0.53, 2.7]

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self

        sceneView.showsStatistics = true

        let scene = SCNScene()

        sceneView.scene = scene
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let referenceImages = Set(ViewController.widths.enumerated().map { x -> ARReferenceImage in
            let (index, width) = x

            let sample = UIImage(named: "sample\(index)")!

            let arrImage = ARReferenceImage(sample.cgImage!, orientation: .up, physicalWidth: CGFloat(width))

            arrImage.name = "replacement\(index)"

            return arrImage
        })

        let configuration = ARWorldTrackingConfiguration()

        configuration.detectionImages = referenceImages

        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return
        }

        let referenceImage = imageAnchor.referenceImage

        guard let referenceId = referenceImage.name else {
            return
        }

        var imageNode = nodesToRemove[referenceId]


        if nil != imageNode {
            nodesToRemove.removeValue(forKey: referenceId)

            print("activated")
        }
        else {
            let replacementImage = UIImage(named: referenceId)

            let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)

            plane.firstMaterial?.diffuse.contents = replacementImage

            let planeNode = SCNNode(geometry: plane)

            planeNode.eulerAngles.x = -.pi / 2

            let containerNode = SCNNode()

            containerNode.addChildNode(planeNode)

            self.sceneView.scene.rootNode.addChildNode(containerNode)

            print("created")

            imageNode = containerNode
        }

        activeImageNodes[referenceId] = imageNode

//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            self.sceneView.session.remove(anchor: imageAnchor)
//
//            let node = self.activeImageNodes[referenceId]
//
//            self.activeImageNodes.removeValue(forKey: referenceId)
//            self.nodesToRemove[referenceId] = node
//
//            print("deactivated")
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//                guard self.nodesToRemove.keys.contains(referenceId) else {
//                    return
//                }
//
//                let node = self.nodesToRemove[referenceId]
//
//                self.nodesToRemove.removeValue(forKey: referenceId)
//
//                node!.removeFromParentNode()
//
//                print("removed")
//            }
//        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return
        }

        let referenceImage = imageAnchor.referenceImage

        guard let referenceId = referenceImage.name else {
            return
        }

        if let imageNode = activeImageNodes[referenceId] ?? nodesToRemove[referenceId] {
            let newTransform = sceneView.scene.rootNode.convertTransform(SCNMatrix4Identity, from: node)

            imageNode.transform = newTransform
        }
    }
}