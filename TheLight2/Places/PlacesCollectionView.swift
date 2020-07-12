//
//  File.swift
//  TheLight2
//
//  Created by Peter Balsamo on 9/22/18.
//  Copyright © 2018 Peter Balsamo. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
final class PlacesCollectionView: UICollectionViewController, UIGestureRecognizerDelegate {
    
    fileprivate let cellId = "cellId"
    private var isMenuOpened = false

    lazy var placeMenu: PlaceMenuBar = {
        let mb = PlaceMenuBar()
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.placeController = self
        return mb
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupMenuBar()
        setupNavigation()
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        collectionView.refreshControl = refresh

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupMenuBar() {
        
        view.addSubview(placeMenu)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            placeMenu.topAnchor.constraint(equalTo: guide.topAnchor),
            placeMenu.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            placeMenu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            placeMenu.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupCollectionView() {

        view.addSubview(collectionView!)
        collectionView?.contentInset = .init(top: 50,left: 0,bottom: 0,right: 0)
        collectionView?.scrollIndicatorInsets = .init(top: 50,left: 0,bottom: 0,right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView.isPagingEnabled = true
        collectionView?.backgroundColor = .secondarySystemGroupedBackground
        collectionView?.register(PlaceFeedCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    private func setupNavigation() {
        
        navigationItem.title = "MileIQ"
        navigationController?.navigationBar.barTintColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemGray
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.black]
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "link"), style: .plain, target: self, action: #selector(self.actionButton))
        let hideButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.left.circle"), style: .plain, target: self, action: #selector(handleHide))
        navigationItem.rightBarButtonItems = [addButton, hideButton]
        
        let gridButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(handleOpen))
        navigationItem.leftBarButtonItems = [gridButton]
    }
    
    // MARK: - NavigationController Hidden

    @objc func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        navigationController?.setNavigationBarHidden(state, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.tabBarController?.hideTabBarAnimated(hide: state) //added
        }, completion: nil)
    }
    // MARK: - Side Menu

    fileprivate func setupTouchGesture() {
        if(isMenuOpened) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss))
            view.addGestureRecognizer(tapGesture)
        } else{
            view.gestureRecognizers?.removeAll(keepingCapacity: false)
        }
    }

    @objc private func handleTapDismiss() {
        handleHide()
    }
    let menuController = MenuController()
    fileprivate let menuWidth: CGFloat = 300.0
    
    @objc func handleOpen() {
        isMenuOpened = true
        setupTouchGesture()
        menuController.view.frame = .init(x: -300, y: 0, width: 300, height: view.frame.height)
        let windows = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        windows?.addSubview(menuController.view)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.menuController.view.transform = CGAffineTransform(translationX: 300, y: 0)
        }, completion: nil)
        addChild(menuController) 
    }
    
    @objc func handleHide() {
        isMenuOpened = false
        setupTouchGesture()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.menuController.view.transform = .identity
        }, completion: nil)
    }

 @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {

        } else if gesture.state == .ended {
            handleHide()
        }
    }
    
    // MARK: - Button

    @objc func actionButton(_ sender: AnyObject) {
        
        let date = Date()
        let calendar = Calendar.current

        let monthInt = calendar.dateComponents([.month], from: Date()).month!
        let monthStr = calendar.monthSymbols[monthInt-1]
        let monthStr1 = calendar.monthSymbols[monthInt-2]
        let monthStr2 = calendar.monthSymbols[monthInt-3]
        let yearCount = calendar.component(.year, from: date)
        let yearCount1 = calendar.component(.year, from: date) - 1
        
        let alert = UIAlertController(title:"Send reports to:", message:"eunited@optonline", preferredStyle: .actionSheet)
        
        let buttonOne = UIAlertAction(title: "\(monthStr) \(String(yearCount))", style: .default, handler: { (action) in

        })
        let buttonTwo = UIAlertAction(title: "\(monthStr1) \(String(yearCount))", style: .default, handler: { (action) in
        
        })
        let buttonThree = UIAlertAction(title: "\(monthStr2) \(String(yearCount))", style: .default, handler: { (action) in
  
        })
        let buttonFour = UIAlertAction(title: "\(String(yearCount)) YTD", style: .default, handler: { (action) in

        })
        let buttonLast = UIAlertAction(title: String(yearCount1), style: .default, handler: { (action) in
            
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        alert.addAction(buttonOne)
        alert.addAction(buttonTwo)
        alert.addAction(buttonThree)
        alert.addAction(buttonFour)
        alert.addAction(buttonLast)
        alert.addAction(buttonCancel)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alert, animated: true)
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

    // MARK: - collectionView

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
            self.collectionViewLayout.invalidateLayout()
        })
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let identifier: String
        identifier = cellId

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)

        return cell
    }
}
@available(iOS 13.0, *)
extension PlacesCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: view.frame.height)
    }
    
    @objc func refresh() {
        //addItem()
        collectionView.refreshControl?.endRefreshing()
    }
}
