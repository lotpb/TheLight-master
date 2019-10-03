//
//  Web.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/9/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

final class Web: UIViewController, UISplitViewControllerDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var recentPostsButton: UIBarButtonItem!
    @IBOutlet weak var safari: UIBarButtonItem!

    private let siteNames = ["CNN", "Drudge", "cnet", "Appcoda", "Cult of Mac"] //no work only in storyboard
    private let siteAddresses = ["http://www.cnn.com",
                      "http://www.Drudgereport.com",
                      "http://www.cnet.com",
                      "http://www.appcoda.com/tutorials/",
                      "http://www.cultofmac.com/category/news/"]
    
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView: WKWebView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        return webView
    }()

    var url: URL?

       var detailItem: AnyObject? {
           didSet {
               self.configureWeb()
           }
       }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - SplitView
        if UIDevice.current.userInterfaceIdiom == .phone  {
            self.extendedLayoutIncludesOpaqueBars = true
        }
        self.splitViewController?.maximumPrimaryColumnWidth = 300
        //fixed - remove bottom bar
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .primaryHidden
        
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.largeTitleDisplayMode = .never
        
        //toolBar.barTintColor = .red
        toolBar.tintColor = .systemGray
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        recentPostsButton.isEnabled = false
        self.segControl? = UISegmentedControl(items: siteNames)
        setupNavigationButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        setupConstraints()
        configureWeb()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setMainNavItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "loading")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }

    private func setupNavigationButtons() {
        /*
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(backButtonPressed))
        navigationItem.rightBarButtonItems = [actionButton] */
    }
    
    func configureWeb() {
        
        if let detail: AnyObject = detailItem {
            webView.load(URLRequest(url:URL(string: detail as! String)!))
        } else {
            webView.load(URLRequest(url:URL(string: siteAddresses[0])!))
        }
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func setupConstraints() {

        view.insertSubview(webView, belowSubview: progressView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        [webView.topAnchor.constraint(equalTo: view.topAnchor),
         webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
         webView.leftAnchor.constraint(equalTo: view.leftAnchor),
         webView.rightAnchor.constraint(equalTo: view.rightAnchor)].forEach  {
            anchor in
            anchor.isActive = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "loading") {
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
        }
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        if (self.webView.canGoBack) {
            self.webView.goBack()
        }
    }
    
    @IBAction func forwardButtonPressed(_ sender: UIBarButtonItem) {
        if (self.webView.canGoForward) {
            self.webView.goForward()
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: UIBarButtonItem) {
        webView.stopLoading()
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        let request = URLRequest(url:webView.url!)
        webView.load(request)
    }
    
    @IBAction func didPressButton(_ sender: AnyObject) {
        
        let safariVC = SFSafariViewController(url:URL(string: siteAddresses[0])!)
        safariVC.delegate = self
        self.present(safariVC, animated: true)
    }
    
    @IBAction func WebTypeChanged(_ sender : UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
             url = URL(string: siteAddresses[0])!
             let request = URLRequest(url: url!)
             webView.load(request)
        case 1:
             url = URL(string: siteAddresses[1])!
             let request = URLRequest(url: url!)
             webView.load(request)
        case 2:
             url = URL(string: siteAddresses[2])!
             let request = URLRequest(url: url!)
             webView.load(request)
        case 3:
            url = URL(string: siteAddresses[3])!
            let request = URLRequest(url: url!)
            webView.load(request)
        case 4:
            url = URL(string: siteAddresses[4])!
            let request = URLRequest(url: url!)
            webView.load(request)
        default:
            break
        }
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }
}
// MARK: - WKScriptMessageHandler
extension Web: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        print(message.webView as Any)
    }
}
// MARK: - WKNavigationDelegate
extension Web: WKNavigationDelegate, WKUIDelegate {
    
    internal func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        
        let hostname = (navigationAction.request as NSURLRequest).url?.host?.lowercased()
        if navigationAction.navigationType == .linkActivated && hostname!.contains(siteAddresses[0]) {
      //if navigationAction.navigationType == .linkActivated && !(navigationAction.request as NSURLRequest).url!.host!.lowercased().hasPrefix(siteAddresses[1]) {
            UIApplication.shared.open(navigationAction.request.url!)
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
