//
//  Stickers.swift
//  groupProject
//
//  Created by Heimstead, Hunter on 9/27/18.
//  Copyright © 2018 Friedl, Luke. All rights reserved.
//

import UIKit

struct Stickers {
    
    let title: String
    let image: UIImage?
    
    init(title: String, image:UIImage?) {
        self.title = title
        self.image = image
    }
    
    // Below I have created an array that will return any image listed below into the cells of the sticker cell
    static func stickers() -> [Stickers] {
        return[
            Stickers(title: "Cap", image: UIImage(named: "cap.png")),
            Stickers(title: "Moustache", image: UIImage(named: "moustache.png")),
            Stickers(title: "Necklace", image: UIImage(named: "necklace.png"))
        ]
    }
}
