//
//  Filters.swift
//  groupProject
//
//  Created by Corey Sather on 9/30/18.
//  Copyright © 2018 Friedl, Luke. All rights reserved.
//

import UIKit

struct Filter {
    
    let title: String
    let filterName: String
    let image: UIImage?
    
    init(title: String, filterName: String, image: UIImage?) {
        self.title = title
        self.filterName = filterName
        self.image = image
    }
    
    static func allFilters() -> [Filter] {
        return [
            Filter(title: "None", filterName: "None", image: UIImage(named: "none.png")),
            Filter(title: "Sepia", filterName: "CISepiaTone", image: UIImage(named: "sepia.png")),
            Filter(title: "Greyscale", filterName: "CIPhotoEffectMono", image: UIImage(named: "mono.png")),
            Filter(title: "Posterize", filterName: "CIColorPosterize", image: UIImage(named: "posterize.png")),
            Filter(title: "Disc Blur", filterName: "CIDiscBlur", image: UIImage(named: "discBlur.png")),
            Filter(title: "Zoom Blur", filterName: "CIZoomBlur", image: UIImage(named: "zoomBlur.png")),
            Filter(title: "Invert", filterName: "CIColorInvert", image: UIImage(named: "invert.png")),
            Filter(title: "Instance Photo", filterName: "CIPhotoEffectInstant", image: UIImage(named: "instant.png")),
            Filter(title: "Bump Distort", filterName: "CIBumpDistortion", image: UIImage(named: "bumpDistort.png")),
            Filter(title: "Hole Distort", filterName: "CIHoleDistortion", image: UIImage(named: "holeDistort.png")),
            Filter(title: "Pinch Distort", filterName: "CIPinchDistortion", image: UIImage(named: "pinchDistort.png")),
            Filter(title: "Bloom", filterName: "CIBloom", image: UIImage(named: "bloom.png")),
            Filter(title: "Comic", filterName: "CIComicEffect", image: UIImage(named: "comic.png")),
            Filter(title: "Crystallize", filterName: "CICrystallize", image: UIImage(named: "crystallize.png")),
            Filter(title: "Edges", filterName: "CIEdges", image: UIImage(named: "edges.png")),
            Filter(title: "Pixellate", filterName: "CIPixellate", image: UIImage(named: "pixellate.png")),
            Filter(title: "Line Overlay", filterName: "CILineOverlay", image: UIImage(named: "lineOverlay.png")),
            Filter(title: "Kaleidoscope", filterName: "CIKaleidoscope", image: UIImage(named: "kaleidoscope.png"))
        ]
    }
}
