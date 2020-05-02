//
//  LaunchController.swift
//  Wheely
//
//  Created by Student on 2020-04-13.
//  Copyright © 2020 Daniel Abella. All rights reserved.
//

import UIKit

protocol LoginControllerDelegate: class {
    func acceptedTerms()
}

class LaunchController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LoginControllerDelegate {
    
    var homeController: HomeController?
    
    init(homeController: HomeController) {
        super.init(nibName: nil, bundle: nil)
        self.homeController = homeController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cellId = "cellId"
    var termsCellId = "termsCell"
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    let pages: [PageModel] = {
        let firstPage = PageModel(title: "Welcome to the app", message: "This app is a platform to collect and analyze movement data for non-ambulatory users.", imageName: "welcomePage")
        let secondPage = PageModel(title: "Install the rotation sensor on the wheelchair", message: "The rotation sensor should be installed according to the instructions included in the package. If the sensor makes a sound when the magnet passes it is installed correctly.", imageName: "installingSensor")
        let thirdPage = PageModel(title: "Download and turn on the watch app", message: "Simply turn on the app and once you've reached the screen shown you have completed this step.", imageName: "watchOn")
        let fourthPage = PageModel(title: "Beginning a workout", message: "This first tab allows you to begin and end a session. Simply click the start button to begin and click it again to end the workout session.", imageName: "howToBegin")
        let fifthPage = PageModel(title: "Connecting the sensors", message: "Once the application has connected to all sensors the icon will turn green and you can begin the workout session. It can take a while and rememeber to push the wheelchair a few turns so the Tacx sensor turns on.", imageName: "connectingSensors")
        let sixthPage = PageModel(title: "Viewing the data", message: "This second tab allows you to view all of the data collected.", imageName: "viewingData")
        let seventhPage = PageModel(title: "Looking at energy expenditure", message: "This third tab shows you the energy expended and distance travelled during the workout session. There is two energy expenditures calculated. One with Apples watch algorithm and one based on the Tacx sensor.", imageName: "energy")
        let eightPage = PageModel(title: "Choosing which data to view", message: "This fourth tab allows you to choose which data to display in the second tab.", imageName: "pickingWorkout")
        let ninethPage = PageModel(title: "Clicking the wrench allows for a few choices", message: "You can delete all data or export the data through email as well as navigate back to these introductory images.", imageName: "options")
        
        return [firstPage, secondPage, thirdPage, fourthPage, fifthPage, sixthPage, seventhPage, eightPage, ninethPage]
    }()
    
    lazy var pageController: UIPageControl = {
        let pageController = UIPageControl()
        pageController.pageIndicatorTintColor = .lightGray
        pageController.currentPageIndicatorTintColor = UIColor.rgb(red: 247, green: 154, blue: 27)
        pageController.numberOfPages = self.pages.count + 1
        return pageController
    }()
    
    var pageControllerBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(pageController)
        pageControllerBottomAnchor = pageController.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)[1]
        
        registerCells()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / (view.frame.width))
        pageController.currentPage = pageNumber
        if pageNumber == pages.count {
            pageControllerBottomAnchor?.constant = 40
        } else {
            pageControllerBottomAnchor?.constant = 0
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }, completion: nil)
    }
    
    func registerCells() {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(TermsCell.self, forCellWithReuseIdentifier: termsCellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(indexPath.item == pages.count) {
            let termsCell = collectionView.dequeueReusableCell(withReuseIdentifier: termsCellId, for: indexPath) as! TermsCell
            termsCell.delegate = self
            return termsCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell
        
        let page = pages[indexPath.item]
        cell.page = page
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func acceptedTerms() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        guard let mainNavigationController = rootViewController as? MainNavigationController else {return}
        
//        let layout = UICollectionViewFlowLayout()
        mainNavigationController.viewControllers = [self.homeController! as UIViewController]
        
        UserDefaults.standard.setAccepted(value: true)
        
        dismiss(animated: true, completion: nil)
    }
}
