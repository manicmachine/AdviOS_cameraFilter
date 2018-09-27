//
//  ViewController.swift
//  groupProject
//
//  Created by Friedl, Luke on 9/20/18.
//  Copyright © 2018 Friedl, Luke. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Variables
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!

    // MARK: - Outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureImageView: UIImageView!

    // Save Image to Core Data Function
    func saveImageToCoreData( image: UIImage) {
        
        let imagePNG = UIImagePNGRepresentation(image);
        
        // This line was also in the tutorial right after the line above, not sure what it's used for ----->     myCoreDataEntity.imageData = imageData
        /* https://forums.developer.apple.com/thread/40411 */
        
        //Set up context for Core Data Storage
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // 'StoredPhotos' is the name of our CoreData entity
        // This should set the value of 'image' in StoredPhotos
        let entity = NSEntityDescription.entity(forEntityName: "StoredPhotos", in: context)
        let newStoredPhoto = NSManagedObject(entity: entity!, insertInto: context)
        newStoredPhoto.setValue(imagePNG, forKey: "image")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Error: Unable to access camera.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    // MARK: - Functions
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        let image = UIImage(data: imageData)
        captureImageView.image = image
        
        // Our save to core data function
        saveImageToCoreData(image : image!)
        
    }
    
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

