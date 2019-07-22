//
//  File.swift
//  TheLight2
//
//  Created by Peter Balsamo on 9/22/18.
//  Copyright © 2018 Peter Balsamo. All rights reserved.
//

import UIKit


final class PlacesCollectionView: UICollectionViewController, UIGestureRecognizerDelegate {
    
    fileprivate let cellId = "cellId"
    //fileprivate let footerId = "footerId"
    fileprivate var tabBarStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupMenuBar()
        setupNavigation()
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        collectionView.refreshControl = refresh
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(PlacesCollectionView.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        //setupNewsNavigationItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var placeMenu: PlaceMenuBar = {
        let mb = PlaceMenuBar()
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.placeController = self
        return mb
    }()
    
    func setupMenuBar() {
        
        view.addSubview(placeMenu)
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            placeMenu.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        } else {
            placeMenu.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
        
        NSLayoutConstraint.activate([
            placeMenu.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            placeMenu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            placeMenu.heightAnchor.constraint(equalToConstant: 50)
            ])
    }

    func setupCollectionView() {

        self.view.addSubview(collectionView!)
        collectionView?.contentInset = .init(top: 50,left: 0,bottom: 0,right: 0)
        collectionView?.scrollIndicatorInsets = .init(top: 50,left: 0,bottom: 0,right: 0)
        collectionView?.alwaysBounceVertical = true
        
        if #available(iOS 13.0, *) {
            collectionView?.backgroundColor = .secondarySystemGroupedBackground
        } else {
            collectionView?.backgroundColor = Color.Mile.collectColor
        }
        collectionView?.register(PlaceFeedCell.self, forCellWithReuseIdentifier: cellId)
        //collectionView?.register(PlaceFooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerId)
    }
    
    func setupNavigation() {
        
        navigationItem.title = "MileIQ"
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.barTintColor = .systemBackground
        } else {
            navigationController?.navigationBar.barTintColor = .white
        }
        navigationController?.navigationBar.tintColor = .systemGray
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        let addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "note30copy").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(self.actionButton))
        navigationItem.rightBarButtonItems = [addButton]
        
        let gridButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-menu-bar").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleOpen))
        navigationItem.leftBarButtonItems = [gridButton]
    }
    
    // MARK: - NavigationController Hidden
    @objc func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        self.navigationController?.setNavigationBarHidden(state, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.tabBarController?.hideTabBarAnimated(hide: state) //added
        }, completion: nil)
    }
    // MARK: - Side menu
    let menuController = MenuController()
    
    @objc func handleOpen() {
        
        //(UIApplication.shared.keyWindow?.rootViewController as? BaseSlidingController)?.openMenu()
        
        menuController.view.frame = .init(x: -300, y: 0, width: 300, height: self.view.frame.height)
        guard let keyWindow = UIApplication.shared.keyWindow else {return}
        keyWindow.addSubview(menuController.view)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            //          both will work
            //          self.menuController.view.frame = .init(x: 0, y: 0, width: 300, height: self.view.frame.height)
            self.menuController.view.transform = CGAffineTransform(translationX: 300, y: 0)
        }, completion: nil)
        addChild(menuController) 
    }
    
    @objc func handleHide() {
        
        //(UIApplication.shared.keyWindow?.rootViewController as? BaseSlidingController)?.closeMenu()
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.menuController.view.transform = .identity
        }, completion: nil)
        //        menuController.view.removeFromSuperview()
        //        menuController.removeFromParent()
    }
    
    // MARK: - Button
    @objc func actionButton(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title:"Send reports to:", message:"eunited@optonline", preferredStyle: .actionSheet)
        
        let setting = UIAlertAction(title: "October 2018", style: .default, handler: { (action) in

        })
        let buttonTwo = UIAlertAction(title: "September 2018", style: .default, handler: { (action) in
        
        })
        let buttonThree = UIAlertAction(title: "August 2018", style: .default, handler: { (action) in
  
        })
        let buttonFour = UIAlertAction(title: "2018 YTD", style: .default, handler: { (action) in

        })
        let buttonSocial = UIAlertAction(title: "2017", style: .default, handler: { (action) in
            
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        alertController.addAction(setting)
        alertController.addAction(buttonTwo)
        alertController.addAction(buttonThree)
        alertController.addAction(buttonFour)
        alertController.addAction(buttonSocial)
        alertController.addAction(buttonCancel)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alertController, animated: true)
    }
    
    @objc func alertButton(_ sender: AnyObject) {
        
        let alert = UIAlertController(title:"Delete Drive", message:"Are you sure you want to remove this trip from your history", preferredStyle: .alert)
        
        let setting = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
        })
        let buttonTwo = UIAlertAction(title: "It was a bike, run,etc.", style: .default, handler: { (action) in
            
        })
        let buttonThree = UIAlertAction(title: "It was public transit", style: .default, handler: { (action) in
            
        })
        let buttonFour = UIAlertAction(title: "Other Reason", style: .default, handler: { (action) in
            
        })
        
        alert.addAction(setting)
        alert.addAction(buttonTwo)
        alert.addAction(buttonThree)
        alert.addAction(buttonFour)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alert, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
            self.collectionViewLayout.invalidateLayout()
        })
    }
}

extension PlacesCollectionView: UICollectionViewDelegateFlowLayout {
    
    // MARK: - collectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier: String
        identifier = cellId
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: view.frame.height)
    }
    /*
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath) as! PlaceFooterCell
        footer.numbersLabel.text = "crap"
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 1 {
            return .zero
        }
        let height = view.frame.height * 0.2
        return .init(width: view.frame.width, height: height)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return 2
        }
        return 1
    } */
    
    @objc func refresh() {
        //addItem()
        collectionView.refreshControl?.endRefreshing()
    }
}
