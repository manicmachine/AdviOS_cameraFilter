//
//  ContainerViewController.swift
//  groupProject
//
//  Created by Corey Sather on 9/30/18.
//  Copyright © 2018 Friedl, Luke. All rights reserved.
//

import UIKit
import QuartzCore
import Photos

class ContainerViewController: UIViewController {

    // MARK: - Variables
    var viewFinderNavigationController: UINavigationController!
    var viewFinderViewController: ViewFinderViewController!
    var filtersViewController: SidePanelViewController?
    var viewFinderExpandedOffset: CGFloat = 175
    var currentState: SlideOutState = .collapsed {
        didSet {
            let shouldShowShadow = currentState != .collapsed
            showShadowForViewFinderViewController(shouldShowShadow)
        }
    }
    
    enum SlideOutState {
        case collapsed
        case leftPanelExpanded
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewFinderViewController = UIStoryboard.viewFinderViewController()
        viewFinderViewController.delegate = self
        viewFinderNavigationController = UINavigationController(rootViewController: viewFinderViewController)
        
        view.addSubview(viewFinderNavigationController.view)
        addChildViewController(viewFinderNavigationController)
        
        viewFinderNavigationController.didMove(toParentViewController: self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        viewFinderNavigationController.view.addGestureRecognizer(panGestureRecognizer)
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }}
    }

}

// MARK: - ViewFinderController delegate
extension ContainerViewController: ViewFinderViewControllerDelegate {
    
    func toggleFiltersPanel() {
        
        let notAlreadyExpanded = ( currentState != .leftPanelExpanded)
        
        if notAlreadyExpanded {
            addFiltersPanelViewController()
        }
        
        animateFiltersPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addFiltersPanelViewController() {
    
        guard filtersViewController == nil else { return }
        
        if let viewController = UIStoryboard.filtersViewController() {
            viewController.filters = Filter.allFilters()
            addChildSidePanelController(viewController)
            filtersViewController = viewController
        }
        
    }
    
    func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {
        
        sidePanelController.delegate = viewFinderViewController
        view.insertSubview(sidePanelController.view, at: 0)
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
        
    }
    
    func animateFiltersPanel(shouldExpand: Bool) {
        
        if shouldExpand {
            currentState = .leftPanelExpanded
            animateViewFinderPanelXPosition(
                targetPosition: viewFinderNavigationController.view.frame.width - viewFinderExpandedOffset)
        } else {
            animateViewFinderPanelXPosition(targetPosition: 0) {
                finished in
                
                self.currentState = .collapsed
                self.filtersViewController?.view.removeFromSuperview()
                self.filtersViewController = nil
            }
        }
        
    }
    
    func animateViewFinderPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut, animations: {
                        self.viewFinderNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    
    }
    
    func showShadowForViewFinderViewController(_ shouldShowShadow: Bool) {
        
        if shouldShowShadow {
            viewFinderNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            viewFinderNavigationController.view.layer.shadowOpacity = 0.0
        }
        
    }
    
}

// MARK: - Extensions

extension ContainerViewController: UIGestureRecognizerDelegate {
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        
        switch recognizer.state {
        case .began:
            addFiltersPanelViewController()
            showShadowForViewFinderViewController(true)
            
        case .changed:
            if let rview = recognizer.view {
                rview.center.x = rview.center.x + recognizer.translation(in: view).x
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
            
        case .ended:
            if let rview = recognizer.view {
                let hasMovedGreaterThanHalfway = rview.center.x > view.bounds.size.width
                animateFiltersPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
            
        default:
            break
        }
    }
    
}

private extension UIStoryboard {
    
    static func mainStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    static func filtersViewController() -> SidePanelViewController? {
        return mainStoryBoard().instantiateViewController(withIdentifier: "FiltersViewController") as? SidePanelViewController
    }
    
    static func viewFinderViewController() -> ViewFinderViewController? {
        return mainStoryBoard().instantiateViewController(withIdentifier: "ViewFinderViewController") as? ViewFinderViewController
    }
}
