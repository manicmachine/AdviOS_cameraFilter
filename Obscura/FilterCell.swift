//
//  FilterCell.swift
//  groupProject
//
//  Created by Corey Sather on 9/30/18.
//  Copyright © 2018 Friedl, Luke. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {
    
    @IBOutlet weak var filterSampleImage: UIImageView!
    @IBOutlet weak var filterTitle: UILabel!
    @IBOutlet weak var filterName: UILabel!
    
    func configureForFilter(_ filter: Filter) {
        filterSampleImage.image = filter.image
        filterTitle.text = filter.title
        filterName.text = filter.filterName
    }
}
