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
import CoreData

class ViewFinderViewController: UIViewController {
    
    // MARK: - Variables
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var previewOutput: AVCaptureVideoDataOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var delegate: ViewFinderViewControllerDelegate?
    var photos: [NSManagedObject] = []
    var currentPhotoID: Int16 = 0
    
    var currentFilter: String = "None"

    // MARK: - Outlets
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var selectedFilterView: UIImageView!
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureImageView.layer.borderWidth = 1
        captureImageView.layer.borderColor =  UIColor.black.cgColor
        selectedFilterView.layer.borderWidth = 1
        selectedFilterView.layer.borderColor = UIColor.black.cgColor
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
            previewOutput = AVCaptureVideoDataOutput()
            previewOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) && captureSession.canAddOutput(previewOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                captureSession.addOutput(previewOutput)
                setupLivePreview()
            }
            
        }
        catch let error {
            print("Error: Unable to initialize back camera: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FilteredPhoto")
        
        do {
            photos = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch photos. \n\(error), \(error.userInfo)")
        }
        
        if (photos.count > 0) {
            captureImageView.image = UIImage(data: photos[photos.count - 1].value(forKey: "photoData") as! Data)
        }
    }
    
    // Capture session cleanup.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ImageGalleryViewController {
            let imageGallery = segue.destination as? ImageGalleryViewController
            imageGallery?.photos = photos
        }
    }
    
    // MARK: - Functions
    // Initialize and configure video preview.
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
        
    }
    
    func savePhoto(_ image: UIImage) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FilteredPhoto", in: managedContext)!
        let photo = NSManagedObject(entity: entity, insertInto: managedContext)
        
        photo.setValue(currentPhotoID + 1, forKeyPath: "photoID")
        photo.setValue(UIImageJPEGRepresentation(image, 1.0), forKeyPath: "photoData")
        
        do {
            try managedContext.save()
            photos.append(photo)
        } catch let error as NSError {
            print("Could not save photo. \n\(error), \(error.userInfo)")
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
    
    static let imageContext = CIContext(options: nil)
    
    // Handle finished photo from stream
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        // Apply filter and output the new image
        var ciImage = CIImage(data: imageData)
        if currentFilter != "None" {
            ciImage = ciImage?.applyingFilter(currentFilter)
        }
        
        // Convert CIImage back to Data by converting CIImage > CGImage > UIImage
        // to fix photo orientation as photos are taken in landscape by default
        // and CIImage strips orientation data. Converting directly from CIImage
        // to UIImage fails to adjust orientation by itself.
        let tempImage: CGImage = ViewFinderViewController.imageContext.createCGImage(ciImage!, from: ciImage!.extent)!
        let uiImage = UIImage(cgImage: tempImage, scale: 1.0, orientation: .right)
        
        captureImageView.image = uiImage
        
        // Write image to local photo album.
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        savePhoto(uiImage)
    }
}

extension ViewFinderViewController: SidePanelViewControllerDelegate {
    
    // Switch currently used filter to whichever was selected and set the
    // selectedFilterView's image.
    func didSelectFilter(_ filter: Filter) {
        
        selectedFilterView.image = filter.image
        currentFilter = filter.filterName        
        delegate?.toggleFiltersPanel?()
    }
    
}

extension ViewFinderViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput!, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        var ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        
        if currentFilter != "None" {
            ciImage = ciImage.applyingFilter(currentFilter)
        }
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return  }
        
        let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
        
        DispatchQueue.main.async {
            self.previewView.image = uiImage
        }
        
    }
    
}
