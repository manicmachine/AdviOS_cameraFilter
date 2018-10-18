//
//  ImageGalleryViewController.swift
//  Obscura
//
//  Created by Corey Sather on 10/16/18.
//  Copyright © 2018 Friedl, Luke. All rights reserved.
//

import UIKit
import CoreData

class ImageGalleryViewController: UICollectionViewController {

    // MARK: - Variables
    private let reuseIdentifier = "PhotoCell"
    var photos: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> FilteredPhotoCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FilteredPhotoCell
    
        cell.photo.image = getPhoto(indexPath)
        cell.photoID = getPhotoId(indexPath)
        
        return cell
    }
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FilteredPhotoCell
//
//        print("Photo ID: \(cell.photoID)");
//    }
    
    // MARK: - Functions
    
    func getPhoto(_ photoIndex: IndexPath) -> UIImage {
        let filteredPhoto = photos[photoIndex.item]
        return UIImage(data: filteredPhoto.value(forKey: "photoData") as! Data)!
    }
    
    func getPhotoId(_ photoIndex: IndexPath) -> Int16 {
        let filteredPhoto = photos[photoIndex.item]
        return filteredPhoto.value(forKey: "photoID") as! Int16
    }

}
