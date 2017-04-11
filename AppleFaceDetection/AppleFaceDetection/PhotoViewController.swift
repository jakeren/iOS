//
//  ViewController.swift
//  AppleFaceDetection
//
//  Created by Wei Chieh Tseng on 11/04/2017.
//  Copyright © 2017 Willjay. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var faceImageView: UIImageView!
    
    @IBOutlet weak var overlay: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func faceRecognitionClicked(_ sender: UIBarButtonItem) {
        // Face Detection with CIDetector
        guard let image = faceImageView.image,
            let ciImage = CIImage(image: image) else { return }
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)

        // For converting the Core Image Coordinates to UIView Coordinates
        let detectedImageSize = ciImage.extent.size
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -detectedImageSize.height)
        
        
        let translate = CGAffineTransform.identity.translatedBy(x: (self.view.frame.size.width - (self.faceImageView.image?.size.width)!) / 2, y: (self.view.frame.size.height - (self.faceImageView.image?.size.height)!) / 2)

        if let faces = faceDetector?.features(in: ciImage, options: [CIDetectorSmile: true, CIDetectorEyeBlink: true]) {
            print(faces.count)
            for face in faces as! [CIFaceFeature] {
                // Apply the transform to convert the coordinates
                let bounds =  face.bounds.applying(transform)
                
                // Calculate the actual position and size of the rectangle in the image view
                let facebounds = bounds.applying(translate)

                DrawingUtility.addRectangle(facebounds, to: self.overlay, with: .red)
                
                // mouth
                if face.hasMouthPosition {
                    let bounds = face.mouthPosition.applying(transform)
                    let point = bounds.applying(translate)
                    
                    DrawingUtility.addCircle(at: point, to: self.overlay, with: .green, withRadius: 6)
                }
                
                // eyes
                if face.hasLeftEyePosition {
                    let bounds = face.leftEyePosition.applying(transform)
                    let point = bounds.applying(translate)
                    
                    DrawingUtility.addCircle(at: point, to: self.overlay, with: .blue, withRadius: 4)
                }
                
                if face.hasRightEyePosition {
                    let bounds = face.rightEyePosition.applying(transform)
                    let point = bounds.applying(translate)
                    
                    DrawingUtility.addCircle(at: point, to: self.overlay, with: .blue, withRadius: 4)
                }
                
                // smile
                if face.hasSmile {
                    let text = String(format: "😀")
                    let rect = CGRect(x: face.bounds.minX, y: face.bounds.maxY + 10, width: self.overlay.frame.size.width, height: 30).applying(transform).applying(translate)
                    DrawingUtility.addTextLabel(text, at: rect, to: self.overlay, with: .green)
                }
                
            }
        }
    }

}

