import SceneKit
import UIKit

extension SCNNode {

    private static func calculateQuaternion(_ startPoint: SCNVector3, _ endPoint: SCNVector3) -> (q0: Float, q1: Float, q2: Float, q3: Float) {

        let w = SCNVector3(
                x: endPoint.x - startPoint.x,
                y: endPoint.y - startPoint.y,
                z: endPoint.z - startPoint.z
        )

        let length = distance(from: startPoint, to: endPoint)

        //original vector of cylinder above 0,0,0
        let originalVector = SCNVector3(0, length / 2.0, 0)
        //target vector, in new coordination
        let newVector = SCNVector3(w.x / 2.0, w.y / 2.0, w.z / 2.0)

        // axis between two vector
        let axisVector = SCNVector3(
                (originalVector.x + newVector.x) / 2.0,
                (originalVector.y + newVector.y) / 2.0,
                (originalVector.z + newVector.z) / 2.0
        )

        //normalized axis vector
        let axisVectorNormalized = axisVector.normalize()

        let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(axisVectorNormalized.x) // x' * sin(angle/2)
        let q2 = Float(axisVectorNormalized.y) // y' * sin(angle/2)
        let q3 = Float(axisVectorNormalized.z) // z' * sin(angle/2)

        return (q0, q1, q2, q3)
    }

    static func distance(from startNode: SCNNode, to endNode: SCNNode) -> CGFloat {
        return distance(from: startNode.position, to: endNode.position)
    }

    static func distance(from startPoint: SCNVector3, to endPoint: SCNVector3) -> CGFloat {
        let directionVector = SCNVector3(
                x: endPoint.x - startPoint.x,
                y: endPoint.y - startPoint.y,
                z: endPoint.z - startPoint.z
        )

        let length = CGFloat(sqrt(pow(directionVector.x, 2) + pow(directionVector.y, 2) + pow(directionVector.z, 2)))

        return length
    }


    func align(from point1:SCNNode, to point2:SCNNode) {
        align(from: point1.position, to: point2.position)
    }

    func align(from startPoint:SCNVector3, to endPoint:SCNVector3) {
        let length = SCNNode.distance(from: startPoint, to: endPoint)

        if length == 0 {
            position = startPoint
        }

        let quaternion = SCNNode.calculateQuaternion(startPoint, endPoint)

        let r11 = pow(quaternion.q0, 2) + pow(quaternion.q1, 2) - pow(quaternion.q2, 2) - pow(quaternion.q3, 2)
        let r12 = 2 * quaternion.q1 * quaternion.q2 + 2 * quaternion.q0 * quaternion.q3
        let r13 = 2 * quaternion.q1 * quaternion.q3 - 2 * quaternion.q0 * quaternion.q2
        let r21 = 2 * quaternion.q1 * quaternion.q2 - 2 * quaternion.q0 * quaternion.q3
        let r22 = pow(quaternion.q0, 2) - pow(quaternion.q1, 2) + pow(quaternion.q2, 2) - pow(quaternion.q3, 2)
        let r23 = 2 * quaternion.q2 * quaternion.q3 + 2 * quaternion.q0 * quaternion.q1
        let r31 = 2 * quaternion.q1 * quaternion.q3 + 2 * quaternion.q0 * quaternion.q2
        let r32 = 2 * quaternion.q2 * quaternion.q3 - 2 * quaternion.q0 * quaternion.q1
        let r33 = pow(quaternion.q0, 2) - pow(quaternion.q1, 2) - pow(quaternion.q2, 2) + pow(quaternion.q3, 2)

        transform.m11 = r11
        transform.m12 = r12
        transform.m13 = r13
        transform.m14 = 0.0

        transform.m21 = r21
        transform.m22 = r22
        transform.m23 = r23
        transform.m24 = 0.0

        transform.m31 = r31
        transform.m32 = r32
        transform.m33 = r33
        transform.m34 = 0.0

        transform.m41 = (startPoint.x + endPoint.x) / 2.0
        transform.m42 = (startPoint.y + endPoint.y) / 2.0
        transform.m43 = (startPoint.z + endPoint.z) / 2.0
        transform.m44 = 1.0
    }
    
    func setScale(value: Float) {
        let scaleVector = SCNVector3(unifiedValue: value)

        scale = scaleVector
    }

    class func axesNode(quiverLength: CGFloat, quiverThickness: CGFloat) -> SCNNode {
        let quiverThickness = (quiverLength / 50.0) * quiverThickness
        let chamferRadius = quiverThickness / 2.0

        let xQuiverBox = SCNBox(width: quiverLength, height: quiverThickness, length: quiverThickness, chamferRadius: chamferRadius)
        xQuiverBox.firstMaterial?.diffuse.contents = UIColor.red
        let xQuiverNode = SCNNode(geometry: xQuiverBox)
        xQuiverNode.position = SCNVector3Make(Float(quiverLength / 2.0), 0.0, 0.0)

        let yQuiverBox = SCNBox(width: quiverThickness, height: quiverLength, length: quiverThickness, chamferRadius: chamferRadius)
        yQuiverBox.firstMaterial?.diffuse.contents = UIColor.green
        let yQuiverNode = SCNNode(geometry: yQuiverBox)
        yQuiverNode.position = SCNVector3Make(0.0, Float(quiverLength / 2.0), 0.0)

        let zQuiverBox = SCNBox(width: quiverThickness, height: quiverThickness, length: quiverLength, chamferRadius: chamferRadius)
        zQuiverBox.firstMaterial?.diffuse.contents = UIColor.blue
        let zQuiverNode = SCNNode(geometry: zQuiverBox)
        zQuiverNode.position = SCNVector3Make(0.0, 0.0, Float(quiverLength / 2.0))

        let quiverNode = SCNNode()
        quiverNode.addChildNode(xQuiverNode)
        quiverNode.addChildNode(yQuiverNode)
        quiverNode.addChildNode(zQuiverNode)
        quiverNode.name = "Axes"
        return quiverNode
    }

    func set(color: UIColor) {
        geometry?.firstMaterial?.diffuse.contents = color
    }
}
