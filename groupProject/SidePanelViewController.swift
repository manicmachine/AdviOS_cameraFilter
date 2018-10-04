//
//  SidePanelViewController.swift
//  groupProject
//
//  Created by Corey Sather on 9/30/18.
//  Copyright © 2018 Friedl, Luke. All rights reserved.
//

import UIKit

class SidePanelViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerImage: UIImageView!
    
    // MARK: - Variables
    var delegate: SidePanelViewControllerDelegate?
    var filters: Array<Filter>!
    
    let cellIdentifier = "FilterCell"
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
}

// MARK: - Data Source
extension SidePanelViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FilterCell
        cell.configureForFilter(filters[indexPath.row])
        
        return cell
    }
    
}

// MARK: - Delegate
extension SidePanelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        delegate?.didSelectFilter(filter)
    }
    
}
