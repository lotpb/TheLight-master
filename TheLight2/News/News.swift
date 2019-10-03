//
//  News.swift
//  TheLight
//
//  Created by Peter Balsamo on 7/12/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit


final class News: UICollectionViewController, SearchDelegate {
    
    private let cellId = "cellId"
    private let trendingCellId = "trendingCellId"
    private let subscriptionCellId = "subscriptionCellId"
    private let accountCellId = "accountId"
    
    private var tabBarStr: String?
    
    private let titles = ["Home", "Trending", "Subscriptions", "Account"]
    
    private var searchController: UISearchController!
    private var resultsController: UITableViewController!
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "  Home"
        if #available(iOS 13.0, *) {
            label.textColor = .systemGray
        } else {
            label.textColor = .black
        }
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.frame = .init(x: 0, y: 0, width: view.frame.width - 32, height: 30)
        self.navigationItem.titleView = self.titleLabel
        self.navigationItem.largeTitleDisplayMode = .never

        setupCollectionView()
        setupMenuBar()
        setupNavigationButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = false
        
        //TabBar Badge
        let tabArray = self.tabBarController?.tabBar.items as NSArray?
        let tabItem = tabArray?.object(at: 2) as? UITabBarItem
        tabItem?.badgeValue = "New" 
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(News.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        setupNewsNavigationItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = true
        //TabBar Badge
        let tabArray = self.tabBarController?.tabBar.items as NSArray?
        let tabItem = tabArray?.object(at: 3) as! UITabBarItem
        tabItem.badgeValue = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupCollectionView() {
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        //added below
        self.view.addSubview(collectionView!)
        collectionView?.contentInset = .init(top: 100,left: 0,bottom: 0,right: 0)
        collectionView?.scrollIndicatorInsets = .init(top: 100,left: 0,bottom: 0,right: 0)
        collectionView?.isPagingEnabled = true
        collectionView?.isDirectionalLockEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.backgroundColor = .black
        
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(TrendingCell.self, forCellWithReuseIdentifier: trendingCellId)
        collectionView?.register(SubscriptionCell.self, forCellWithReuseIdentifier: subscriptionCellId)
        collectionView?.register(AccountCell.self, forCellWithReuseIdentifier: accountCellId)
    }
    
     private func setupNavigationButtons() {
        
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(handleMore))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(newButton))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action:#selector(handleSearch))
        navigationItem.rightBarButtonItems = [moreButton,searchButton,addButton]
    }
    
    // MARK: - NavigationController Hidden
    @objc func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        self.navigationController?.setNavigationBarHidden(state, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.tabBarController?.hideTabBarAnimated(hide: state) //added
        }, completion: nil)
    }
    
    // MARK: - Button
    @objc func newButton(sender: AnyObject) {
        
        self.performSegue(withIdentifier: "uploadSegue", sender: self)
    }
    
    // MARK: - youtube Action Menu
    //-------------------------------------------------
    lazy var search: Search = {
        let se = Search.init(frame: UIScreen.main.bounds)
        se.delegate = self
        return se
    }()
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.homeController = self
        return launcher
    }()
    
    @objc func handleMore() {
        //show menu
        settingsLauncher.showSettings()
    }
    
    func showControllerForSetting(setting: Setting) {
        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = .white
        dummySettingsViewController.navigationItem.title = setting.name.rawValue
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.homeController = self
        return mb
    }()
    
    private func setupMenuBar() {
        
        let redView = UIView()
        if UIDevice.current.userInterfaceIdiom == .pad  {
            redView.backgroundColor = .black
        } else {
            redView.backgroundColor = .systemRed //.systemGroupedBackground
        }
        
        view.addSubview(redView)
        view.addSubview(menuBar)
        
        NSLayoutConstraint.activate([
            redView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            redView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            redView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            redView.heightAnchor.constraint(equalToConstant: 50),
            
            menuBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            menuBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            menuBar.heightAnchor.constraint(equalToConstant: 50)
            ])
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            menuBar.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        } else {
            menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 4
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = targetContentOffset.pointee.x / view.frame.width
        
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        
        setTitleForIndex(index: Int(index))
    }

    func scrollToMenuIndex(menuIndex: Int) {
        
        let indexPath = IndexPath(item: menuIndex, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .right, animated: true)
        
        setTitleForIndex(index: menuIndex)
    }
    
    private func setTitleForIndex(index: Int) {
        
        if let titleLabel = navigationItem.titleView as? UILabel {
            titleLabel.text = "\(titles[index])"
        }
    }
    
    @objc func handleSearch() {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(self.search)
            self.search.animate()
        }
    }
    
    func hideSearchView(status : Bool){
        if status == true {
            self.search.removeFromSuperview()
        }
    }
}

extension News: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier: String
        if indexPath.item == 1 {
            identifier = trendingCellId
        } else if indexPath.item == 2 {
            identifier = subscriptionCellId
        } else if indexPath.item == 3 {
            identifier = accountCellId
        } else {
            identifier = cellId
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: view.frame.height - 50)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }

}

//-----------------------end------------------------------
