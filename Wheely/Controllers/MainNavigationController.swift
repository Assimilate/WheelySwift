//
//  MainNavigationController.swift
//  Wheely
//
//  Created by Student on 2020-04-13.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if hasAcceptedTerms() {
            let layout = UICollectionViewFlowLayout()
            let homeController = HomeController(collectionViewLayout: layout)
            viewControllers = [homeController]
        } else {
            perform(#selector(showLaunchController), with: nil, afterDelay: 0.01)
        }
        
    }
    
    @objc func showLaunchController() {
        let launchController = LaunchController()
        launchController.modalPresentationStyle = .fullScreen
        present(launchController, animated: true) {
            // Might use later.
        }
    }
    
    fileprivate func hasAcceptedTerms() -> Bool {
        return UserDefaults.standard.hasAccepted()
    }
}


