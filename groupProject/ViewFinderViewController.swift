//
//  ViewController.swift
//  groupProject
//
//  Created by Group 1 on 9/20/18.
//  Copyright © 2018 Group 1. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


class ViewFinderViewController: UIViewController {
    
    // MARK: - Variables
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var delegate: ViewFinderViewControllerDelegate?
    
    var currentFilter: String = "None"

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
    
    // MARK: - Functions
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

// MARK: - Extensions
extension ViewFinderViewController : AVCapturePhotoCaptureDelegate {
    
    // Handle finished photo from stream
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        // Apply filter and output the new image
        var image = CIImage(data: imageData)
        if currentFilter != "None" {
            image = image?.applyingFilter(currentFilter)
        }
        
        let uiimage = UIImage(ciImage: image!)
        captureImageView.image = uiimage
        
        // Save image to device's Photo Library
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
        
        PHPhotoLibrary.shared().performChanges({
            UIImageWriteToSavedPhotosAlbum(uiimage, self, #selector(self.logImage), nil)})
//            let creationRequest = PHAssetCreationRequest.forAsset()
//            creationRequest.addResource(with: .photo, data: image., options: nil)})
        }
    }
    
    @objc func logImage() {
        print("Imaged saved...")
    }
}

extension ViewFinderViewController: SidePanelViewControllerDelegate {
    
    // Switch currently used filter to whichever was selected
    func didSelectFilter(_ filter: Filter) {
        
        currentFilter = filter.filterName        
        delegate?.toggleFiltersPanel?()
    }
    
}
