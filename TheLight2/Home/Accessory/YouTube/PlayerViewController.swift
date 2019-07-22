//
//  PlayerViewController.swift
//  YTDemo
//
//  Created by Gabriel Theodoropoulos on 27/6/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import YouTubePlayer

class PlayerViewController: UIViewController {

    @IBOutlet var videoPlayer: YouTubePlayerView!
    
    var videoID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPlayer?.loadVideoID(videoID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    

}
