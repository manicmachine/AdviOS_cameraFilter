//
//  ViewController.swift
//  groupProject
//
//  Created by Group 1 on 9/20/18.
//  Copyright © 2018 Group 1. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: - Variables
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var currentFilter: String = ""
    
    let filters = [
        "Sepia" : "CISepiaTone",
        "Greyscale" : "CIPhotoEffectMono",
        "Posterize" : "CIColorPosterize",
        "Disc Blur" : "CIDiscBlur",
        "Zoom Blur" : "CIZoomBlur",
        "Invert Color" : "CIColorInvert",
        "Instant Photo" : "CIPhotoEffectInstant",
        "Bump Distort" : "CIBumpDistortion",
        "Hole Distort" : "CIHoleDistortion",
        "Pinch Distort" : "CIPinchDistortion",
        "Bloom" : "CIBloom",
        "Comic" : "CIComicEffect",
        "Crystalize" : "CICrystallize",
        "Edges" : "CIEdges",
        "Pixellate" : "CIPixellate",
        "Line Overlay" : "CILineOverlay",
        "Kaleidoscope" : "CIKaleidoscope"]

    // MARK: - Outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureImageView: UIImageView!

    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureImageView.layer.borderWidth = 1
        captureImageView.layer.borderColor =  UIColor.black.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Initialize and configure an AVCaptureSession to manage the photostream
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium

        // Configure the input device (front camera). If unable to do so, bail.
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else {
            print("Error: Unable to access camera.")
            return
        }
        
        // Initialize and configure the capture input; passing along the input and output objects.
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
            
        }
        catch let error {
            print("Error: Unable to initialize back camera: \(error.localizedDescription)")
        }
    }
    
    // Capture session cleanup.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    // Initialize and configure video preview 
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.captureSession.startRunning()
          
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
            
        }
        
    }
    
    // MARK: - Actions
    @IBAction func didTakePhoto(_ sender: Any) {
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
}

extension ViewController : AVCapturePhotoCaptureDelegate {
    
    // Handle finished photo from stream
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        var image = CIImage(data: imageData)
        image = image?.applyingFilter("CIKaleidoscope")
        captureImageView.image = UIImage(ciImage: image!)
        
    }
    
}
