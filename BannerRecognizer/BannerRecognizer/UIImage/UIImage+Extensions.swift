//
// Created by Igor Djachenko on 27/02/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

import Foundation

extension UIImage {
    static func from(buffer pixelBuffer: CVPixelBuffer) -> UIImage {
        let preImage = CIImage(cvPixelBuffer: pixelBuffer)

        let imageContext = CIContext()
        let renderedImage = imageContext.createCGImage(preImage, from: preImage.extent)!

        let image = UIImage(cgImage: renderedImage)

        return image
    }

    public func rotatedBy(degrees: CGFloat) -> UIImage? {
        let rotatedSize = CGSize(width: size.height, height: size.width)

        UIGraphicsBeginImageContext(rotatedSize)

        let bitmap = UIGraphicsGetCurrentContext()!

        bitmap.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);
        bitmap.rotate(by: .pi / 2);
        bitmap.translateBy(x: -rotatedSize.height / 2.0, y: -rotatedSize.width / 2.0);

        self.draw(at: .zero)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return newImage
    }

    func color(at point: CGPoint) -> UIColor {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(self.size.width) * Int(point.y)) + Int(point.x)) * 4

        let r = CGFloat(data[pixelInfo])
        let g = CGFloat(data[pixelInfo + 1])
        let b = CGFloat(data[pixelInfo + 2])
        let a = CGFloat(data[pixelInfo + 3])

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}