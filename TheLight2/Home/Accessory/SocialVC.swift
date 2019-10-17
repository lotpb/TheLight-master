//
//  SocialController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/12/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import Social


@available(iOS 13.0, *)
final class SocialVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var noteTextview: UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.view.backgroundColor = .secondarySystemGroupedBackground
        self.noteTextview.backgroundColor = .systemBackground
        configureNoteTextView()
        noteTextview.delegate = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - Social"
        } else {
            navigationItem.title = "Social"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Fix Grey Bar in iphone Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        setMainNavItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showShareOptions(_ sender: AnyObject) {
        
        if noteTextview.isFirstResponder {
            noteTextview.resignFirstResponder()
        }
        
        let url = URL.init(string: "http://lotpb.github.io/UnitedWebPage/index.html")!
        
        let share = [self.noteTextview.text!, url] as [Any]
        let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true)
    }

    // MARK: Custom Functions
    func configureNoteTextView() {
        noteTextview.layer.cornerRadius = 8.0
        noteTextview.layer.borderColor = UIColor(white: 0.75, alpha: 0.5).cgColor
        noteTextview.layer.borderWidth = 1.2
    }
    
    // MARK: UITextViewDelegate Functions
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    // MARK: - Button
    
}

