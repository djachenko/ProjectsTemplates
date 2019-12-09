//
// Created by Igor Djachenko on 25/01/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

import Foundation
import ARCL
import UIKit
import CoreLocation
import SceneKit

class VisibilityViewController: UIViewController {
    @IBOutlet private var sceneView: SceneLocationView!

    private let locationManager = CLLocationManager()

    private let testPoint = CGPoint(54.855873, 83.096799)

    private var userLocation = CLLocation(latitude: 0, longitude: 0, altitude: 0)

//    let cubeCoordinates = [
//        CLLocationCoordinate2D(latitude: 54.857767, longitude: 83.105063), //parking
//        CLLocationCoordinate2D(latitude: 54.858016, longitude: 83.106131), //between F
//        CLLocationCoordinate2D(latitude: 54.858573, longitude: 83.106264), //above
//        CLLocationCoordinate2D(latitude: 54.859398, longitude: 83.104686) //before edem
//    ]
//
//    let altitude: CLLocationDistance = 148
//
//
//
//    let buildingCorners = [
//        CLLocationCoordinate2D(latitude: 54.858013, longitude: 83.105158),
//        CLLocationCoordinate2D(latitude: 54.858156, longitude: 83.105499),
//        CLLocationCoordinate2D(latitude: 54.857811, longitude: 83.105949),
//        CLLocationCoordinate2D(latitude: 54.857893, longitude: 83.106134),
//        CLLocationCoordinate2D(latitude: 54.858190, longitude: 83.105759),
//        CLLocationCoordinate2D(latitude: 54.858329, longitude: 83.106089),
//        CLLocationCoordinate2D(latitude: 54.858049, longitude: 83.106478),
//        CLLocationCoordinate2D(latitude: 54.858112, longitude: 83.106639),
//        CLLocationCoordinate2D(latitude: 54.858513, longitude: 83.106129),
//        CLLocationCoordinate2D(latitude: 54.858131, longitude: 83.105179),
//        CLLocationCoordinate2D(latitude: 54.858191, longitude: 83.105094),
//        CLLocationCoordinate2D(latitude: 54.858140, longitude: 83.104970)
//    ]




    let cubeCoordinates = [
        CLLocationCoordinate2D(latitude: 54.858414, longitude: 83.105425),
        CLLocationCoordinate2D(latitude: 54.858974, longitude: 83.105821),
        CLLocationCoordinate2D(latitude: 54.858395, longitude: 83.104432),
        CLLocationCoordinate2D(latitude: 54.858925, longitude: 83.104802)
    ]



    let altitude: CLLocationDistance = 148

    let buildingCorners = [
        CLLocationCoordinate2D(latitude: 54.858634, longitude: 83.104273),
        CLLocationCoordinate2D(latitude: 54.859141, longitude: 83.105491),
        CLLocationCoordinate2D(latitude: 54.858755, longitude: 83.105984),
        CLLocationCoordinate2D(latitude: 54.858247, longitude: 83.104772)
    ]







    private func createCube() -> SCNBox {
        let cubeSize: CGFloat = 3
        let cubeGeometry = SCNBox(width: cubeSize, height: cubeSize, length: cubeSize, chamferRadius: 0)

        cubeGeometry.firstMaterial?.diffuse.contents = UIColor.blue

        return cubeGeometry
    }

    private func createPillar() -> SCNCylinder {
        let radius: CGFloat = 1
        let height: CGFloat = 500

        let pillarGeometry = SCNCylinder(radius: radius, height: height)

        pillarGeometry.firstMaterial?.diffuse.contents = UIColor.cyan

        return pillarGeometry
    }

    var cubeNodes: [LocationNode] = []

    var building: Building!

    override func viewDidLoad() {
        super.viewDidLoad()

        Segment.test()

        userLocation = CLLocation(latitude: CLLocationDegrees(testPoint.x), longitude: CLLocationDegrees(testPoint.y), altitude: 0)


        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self


        cubeNodes = cubeCoordinates.map { coordinate in
            let cube = createCube()

            let locationNode = LocationNode(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude, altitude: altitude))

            locationNode.geometry = cube

            return locationNode
        }

        cubeNodes.forEach { node in
            sceneView.addLocationNodeWithConfirmedLocation(locationNode: node)
        }

        building = Building(corners: buildingCorners.map { CGPoint(coordinate: $0) })

        let cornerNodes = buildingCorners.map { cornerCoordinate -> LocationNode in
            let locationNode = LocationNode(location: CLLocation(coordinate: cornerCoordinate, altitude: altitude))

            locationNode.geometry = createPillar()

            return locationNode
        }

        cornerNodes.forEach { node in
            sceneView.addLocationNodeWithConfirmedLocation(locationNode: node)
        }

        sceneView.autoenablesDefaultLighting = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.pause()
    }
}

extension VisibilityViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        userLocation = locations.last!

        print("user loc \(userLocation.coordinate)")

        let cameraCoordinate = userLocation.coordinate

        cubeNodes.forEach { node in
            let nodeCoordinate = node.location.coordinate

            if building.between(point: CGPoint(coordinate: cameraCoordinate), point: CGPoint(coordinate: nodeCoordinate)) {
                node.set(color: .red)
            }
            else {
                node.set(color: .green)
            }
        }
    }
}
