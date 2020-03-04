//
//  UIImageExt.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import AVKit

extension UIImage {
  static func resizeImage(originalImage: UIImage, rect: CGRect) -> UIImage {
    let rect = AVMakeRect(aspectRatio: originalImage.size, insideRect: rect)
    let size = CGSize(width: rect.width, height: rect.height)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { (context) in
      originalImage.draw(in: CGRect(origin: .zero, size: size))
    }
  }
}
