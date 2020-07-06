//
//  BaseSlidingControllerViewController.swift
//  SlideOutMenu
//
//  Created by ivica petrsoric on 14/10/2018.
//  Copyright © 2018 ivica petrsoric. All rights reserved.
//

import UIKit

class RedViewContainer: UIView {}
class MenuContainerView: UIView {}
class DarkCoverView: UIView {}

@available(iOS 13.0, *)
class BaseSlidingController: UIViewController {

    let redView: RedViewContainer = {
        let view = RedViewContainer()
        view.backgroundColor = .systemRed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let blueView: MenuContainerView = {
        let view = MenuContainerView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let darkCoverView: DarkCoverView = {
        let view = DarkCoverView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss))
        darkCoverView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTapDismiss() {
        handleHide()
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        var x = translation.x
        
        x = isMenuOpened ? x + menuWidth : x
        x = min(menuWidth, x)
        x = max(0, x)
        
        redViewLeadingConstraint.constant = x
        redViewTrailingConstrant.constant = x
        darkCoverView.alpha = x / menuWidth
        
        if gesture.state == .ended {
            handleEnded(gesture: gesture)
        }
    }
    
    private func handleEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        if isMenuOpened {
            if abs(velocity.x) > velocityThreshold {
                handleHide()
                return
            }
            if abs(translation.x) < menuWidth / 2 {
                openMenu()
            } else {
                handleHide()
            }
        } else {
            if abs(velocity.x) > velocityThreshold {
                openMenu()
                return
            }
            
            if translation.x < menuWidth / 2 {
                handleHide()
            } else {
                openMenu()
            }
        }
    }
    
    func openMenu() {
        isMenuOpened = true
        redViewLeadingConstraint.constant = menuWidth
        redViewTrailingConstrant.constant = menuWidth
        performAnimations()
    }
    
    func handleHide() {
        redViewLeadingConstraint.constant = 0
        redViewTrailingConstrant.constant = 0
        isMenuOpened = false
        performAnimations()
    }
    
    func didSelectMenuItem(indexPath: IndexPath) {
        performRightViewCleanUp()
        handleHide()
        
        switch indexPath.row {
        case 0:
            rightViewController = LeadUserVC()
            
        case 1:
            let navController = UINavigationController(rootViewController: ListController())
            redView.addSubview(navController.view)
            addChild(navController)
            rightViewController = navController
            
        case 2:
            let bookmarksController = BookmarksController()
            redView.addSubview(bookmarksController.view)
            addChild(bookmarksController)
            rightViewController = bookmarksController
            
        case 3:
            let tabBarController = UITabBarController()
            let momentsController = UIViewController()
            momentsController.navigationItem.title = "Moments"
            momentsController.view.backgroundColor = .systemOrange
            
            let testController = UIViewController()
            testController.view.backgroundColor = .systemGreen
            testController.tabBarItem.title = "Test"
            
            let navController = UINavigationController(rootViewController: momentsController)
            navController.tabBarItem.title = "moments"
            tabBarController.viewControllers = [navController, testController]
            rightViewController = tabBarController
            
        default:
            blueView.isHidden = true
            navigationController?.popToRootViewController(animated: true)
        }
        
        redView.addSubview(rightViewController.view)
        addChild(rightViewController)
        
        redView.bringSubviewToFront(darkCoverView)
    }

    var rightViewController: UIViewController = UINavigationController(rootViewController: PlacesCollectionView(collectionViewLayout: UICollectionViewFlowLayout()))
    
    let menuController = MenuController()
    
    private func performRightViewCleanUp() {
        rightViewController.view.removeFromSuperview()
        rightViewController.removeFromParent()
    }
    
    private func performAnimations() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            // leave a reference link down in desc below
            self.view.layoutIfNeeded()
            self.darkCoverView.alpha = self.isMenuOpened ? 1 : 0
        })
    }
    
    var redViewLeadingConstraint: NSLayoutConstraint!
    var redViewTrailingConstrant: NSLayoutConstraint!
    private let menuWidth: CGFloat = 300
    private var isMenuOpened = false
    private let velocityThreshold: CGFloat = 500
    
    private func setupViews() {
        view.addSubview(redView)
        view.addSubview(blueView)
        view.addSubview(darkCoverView)
        
        NSLayoutConstraint.activate([
            redView.topAnchor.constraint(equalTo: view.topAnchor),
            redView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            redView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            redView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            redView.topAnchor.constraint(equalTo: view.topAnchor),
            redView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            redView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            blueView.topAnchor.constraint(equalTo: view.topAnchor),
            blueView.trailingAnchor.constraint(equalTo: redView.leadingAnchor),
            blueView.widthAnchor.constraint(equalToConstant: menuWidth),
            blueView.bottomAnchor.constraint(equalTo: redView.bottomAnchor)
            ])
        
        //self.redViewLeadingConstraint = redView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        //redViewLeadingConstraint.isActive = true
        
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        rightViewController = UINavigationController(rootViewController: PlacesCollectionView())
        let menuController = GeoMenuController()
        let homeView = rightViewController.view!
        let menuView = menuController.view!
        
        homeView.translatesAutoresizingMaskIntoConstraints = false
        menuView.translatesAutoresizingMaskIntoConstraints = false
        
        blueView.addSubview(menuView)
        redView.addSubview(homeView)
        redView.addSubview(darkCoverView)

        addChild(rightViewController)
        addChild(menuController)
        
        NSLayoutConstraint.activate([
            homeView.topAnchor.constraint(equalTo: redView.topAnchor),
            homeView.leadingAnchor.constraint(equalTo: redView.leadingAnchor),
            homeView.bottomAnchor.constraint(equalTo: redView.bottomAnchor),
            homeView.trailingAnchor.constraint(equalTo: redView.trailingAnchor),
            
            menuView.topAnchor.constraint(equalTo: blueView.topAnchor),
            menuView.leadingAnchor.constraint(equalTo: blueView.leadingAnchor),
            menuView.bottomAnchor.constraint(equalTo: blueView.bottomAnchor),
            menuView.trailingAnchor.constraint(equalTo: blueView.trailingAnchor),
            
            darkCoverView.topAnchor.constraint(equalTo: redView.topAnchor),
            darkCoverView.leadingAnchor.constraint(equalTo: redView.leadingAnchor),
            darkCoverView.bottomAnchor.constraint(equalTo: redView.bottomAnchor),
            darkCoverView.trailingAnchor.constraint(equalTo: redView.trailingAnchor),
            ])
    } 
    
} 
