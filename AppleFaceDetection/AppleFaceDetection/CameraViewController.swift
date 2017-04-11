//
//  CameraViewController.swift
//  AppleFaceDetection
//
//  Created by Wei Chieh Tseng on 11/04/2017.
//  Copyright © 2017 Willjay. All rights reserved.
//

import UIKit
import ImageIO
import AVKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet weak var placeholder: UIView!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var cameraSwitch: UISwitch! {
        didSet {
            devicePosition = self.cameraSwitch.isOn ? .back : .front
        }
    }
    
    var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    
    
    var lastKnownDeviceOrientation: UIDeviceOrientation = .unknown
    
    var captureDevice: AVCaptureDevice!
    var session: AVCaptureSession!
    var videoDataOutput: AVCaptureVideoDataOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var devicePosition: AVCaptureDevicePosition!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up default camera settings.
        self.cameraSwitch.isOn = true
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSessionPresetMedium
        self.updateCameraSelection()
        
        // Setup video processing pipeline.
        self.setupVideoProcessing()
        
        // Setup camera preview.
        self.setupCameraPreview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.layer.bounds
        self.previewLayer.position = CGPoint(x: self.previewLayer.frame.midX, y: self.previewLayer.frame.midY)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.session.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.session.stopRunning()
    }
    
    @IBAction func cameraDeviceChanged(_ sender: UISwitch) {
        updateCameraSelection()
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if self.previewLayer != nil {
            if (toInterfaceOrientation == .portrait) {
                self.previewLayer.connection.videoOrientation = .portrait
            } else if (toInterfaceOrientation == .portraitUpsideDown) {
                self.previewLayer.connection.videoOrientation = .portraitUpsideDown
            } else if (toInterfaceOrientation == .landscapeLeft) {
                self.previewLayer.connection.videoOrientation = .landscapeLeft
            } else if (toInterfaceOrientation == .landscapeRight) {
                self.previewLayer.connection.videoOrientation = .landscapeRight
            }
            
        }
    }
    
    
    func updateCameraSelection() {
        self.session.beginConfiguration()
        // Remove old inputs
        let oldInputs = self.session.inputs as! [AVCaptureInput]
        for oldInput in oldInputs {
            self.session.removeInput(oldInput)
        }
        
        let desiredPosition: AVCaptureDevicePosition = cameraSwitch.isOn ? .back : .front
        captureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: desiredPosition)
        
        do {
            let input = try AVCaptureDeviceInput(device: self.captureDevice)
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.session.commitConfiguration()
            }
        }
            
        catch {
            // Failed, restore old inputs
            for oldInput in oldInputs {
                self.session.addInput(oldInput)
            }
            self.session.commitConfiguration()
        }
        
    }
    
    func setupVideoProcessing() {
        self.videoDataOutput = AVCaptureVideoDataOutput()
        let rgbOutputSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)]
        self.videoDataOutput.videoSettings = rgbOutputSettings
        
        if !self.session.canAddOutput(videoDataOutput) {
            cleanupVideoProcessing()
            print("Failed to setup video output")
            return
        }
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        self.session.addOutput(videoDataOutput)
        
    }
    
    func cleanupVideoProcessing() {
        if (videoDataOutput != nil) {
            self.session.removeOutput(videoDataOutput)
        }
        self.videoDataOutput = nil
    }
    
    func setupCameraPreview() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer.backgroundColor = UIColor.white.cgColor
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        let rootLayer = self.placeholder.layer
        rootLayer.masksToBounds = true
        self.previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(self.previewLayer)
    }

    func getDeviceOrientation() -> AVCaptureVideoOrientation? {
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return nil
        }
    }

    func scaledRect(_ rect: CGRect, xScale xscale: CGFloat, yScale yscale: CGFloat, offset: CGPoint) -> CGRect {
        var resultRect = CGRect(x: CGFloat(rect.origin.x * xscale), y: CGFloat(rect.origin.y * yscale), width: CGFloat(rect.size.width * xscale), height: CGFloat(rect.size.height * yscale))
        resultRect = resultRect.offsetBy(dx: CGFloat(offset.x), dy: CGFloat(offset.y))
        return resultRect
    }

}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard  let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
        let orientation = getDeviceOrientation() else {
            return
        }


        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]

        // For converting the Core Image Coordinates to UIView Coordinates
        let detectedImageSize = ciImage.extent.size
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -detectedImageSize.height)


        
        // The video frames captured by the camera are a different size than the video preview.
        // Calculates the scale factors and offset to properly display the features.
        let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer)
        let clap = CMVideoFormatDescriptionGetCleanAperture(fdesc!, false)
        let parentFrameSize = self.previewLayer.frame.size
        
        // Assume AVLayerVideoGravityResizeAspect
        let cameraRatio = clap.size.height / clap.size.width
        let viewRatio = parentFrameSize.width / parentFrameSize.height
        var xScale: CGFloat = 1, yScale: CGFloat = 1
        var videoBox = CGRect.zero
        
        if (viewRatio > cameraRatio) {
            videoBox.size.width = parentFrameSize.height * clap.size.width / clap.size.height
            videoBox.size.height = parentFrameSize.height
            videoBox.origin.x = (parentFrameSize.width - videoBox.size.width) / 2
            videoBox.origin.y = (videoBox.size.height - parentFrameSize.height) / 2
            
            xScale = videoBox.size.width / clap.size.width
            yScale = videoBox.size.height / clap.size.height
        } else {
            videoBox.size.width = parentFrameSize.width
            videoBox.size.height = clap.size.width * (parentFrameSize.width / clap.size.height);
            videoBox.origin.x = (videoBox.size.width - parentFrameSize.width) / 2
            videoBox.origin.y = (parentFrameSize.height - videoBox.size.height) / 2
            
            xScale = videoBox.size.width / clap.size.height
            yScale = videoBox.size.height / clap.size.width
        }
        
        // Calculate the actual position and size of the rectangle in the image view
        let translate = CGAffineTransform.identity.scaledBy(x: xScale, y: yScale).translatedBy(x: videoBox.origin.x, y: videoBox.origin.y)
                
        
        // Establish the image orientation.
        let orientationMap: [AVCaptureVideoOrientation : CGImagePropertyOrientation] = [
            .portrait           : .right,
            .portraitUpsideDown : .left,
            .landscapeLeft      : .down,
            .landscapeRight     : .up,
            ]
        let imageOrientation = Int32(orientationMap[orientation]!.rawValue)
        ciImage.applyingOrientation(imageOrientation)


        if let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy) {
            let faces = faceDetector.features(in: ciImage, options: [CIDetectorSmile: true, CIDetectorEyeBlink: true, CIDetectorImageOrientation: imageOrientation])

            DispatchQueue.main.sync {
                // Remove previously added feature views.
                for featureView in self.overlay.subviews {
                    featureView.removeFromSuperview()
                }
                
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
}
