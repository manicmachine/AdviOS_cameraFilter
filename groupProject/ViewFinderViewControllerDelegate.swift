//
//  ViewFinderViewControllerDelegate.swift
//  groupProject
//
//  Created by Heimstead, Hunter on 9/27/18.
//  Copyright © 2018 Friedl, Luke. All rights reserved.
//

import Foundation

@objc
protocol ViewFinderViewControllerDelegate {
    @objc optional func toggleLeftPanel()
    @objc optional func collapseSidePanels()
}

