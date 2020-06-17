//
//  YouTubeController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/17/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit

final class YouTubeController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segDisplayedContent: UISegmentedControl!
    @IBOutlet weak var viewWait: UIView!
    
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    
    var apiKey = "AIzaSyC-_pCbYwqSIckw4E180Fajj-RycvbKtS8"
    
    var desiredChannelsArray = ["lotpb", "Apple", "CaseyNeistat", "MarkDice", "ESPN", "HOWARDTV", "CodeWithChris", "SergeyKargopolov", "Lifehacker", "JimmyKimmelLive", "latenight", "Microsoft"]
    
    var channelIndex = 0
    var channelsDataArray: Array<Dictionary<String, AnyObject>> = []
    var videosArray: Array<Dictionary<String, AnyObject>> = []
    var selectedVideoIndex: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondarySystemGroupedBackground
        self.extendedLayoutIncludesOpaqueBars = true
        
        getChannelDetails(false)
        setupNavigation()
        //setupSearch()
        setupTableView()
        self.segDisplayedContent.apportionsSegmentWidthsByContent = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupSearch() {
        searchController = UISearchController(searchResultsController: resultsController)
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = UIColor.white
                backgroundview.layer.cornerRadius = 10
                backgroundview.clipsToBounds = true
            }
        }
        
        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for videos"
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        self.definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            //navigationItem.searchController = searchController
            navigationItem.titleView = searchController.searchBar
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            navigationItem.titleView = searchController?.searchBar
        }
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = false
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - YouTube"
        } else {
            navigationItem.title = "YouTube"
        }
    }
    
    func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView!.sizeToFit()
        self.tableView!.clipsToBounds = true
        if #available(iOS 13.0, *) {
            self.tableView!.backgroundColor = .systemGray4
        } else {
            self.tableView!.backgroundColor = UIColor(white:0.90, alpha:1.0)
        }
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        resultsController.tableView.sizeToFit()
        resultsController.tableView.clipsToBounds = true
        resultsController.tableView.backgroundColor = ColorX.LGrayColor
        resultsController.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - IBAction method implementation
    @IBAction func changeContent(_ sender: AnyObject) {
        tableView.reloadSections(IndexSet(integer: 0), with: UITableView.RowAnimation.fade)
    }

    // MARK: UITextFieldDelegate method implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        viewWait.isHidden = false
        
        // Specify the search type (channel, video).
        var type = "channel"
        if segDisplayedContent.selectedSegmentIndex == 1 {
            type = "video"
            videosArray.removeAll(keepingCapacity: false)
        }
        
        // Form the request URL string.
        var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(String(describing: textField.text))&type=\(type)&key=\(apiKey)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        // Create a NSURL object based on the above string.
        let targetURL = URL(string: urlString)
        
        // Get the results.
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error)  in
            if HTTPStatusCode == 200, error == nil {
                // Convert the JSON data to a dictionary object.
                do {
  
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
                    
                    // Get all search result items ("items" array).
                   let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                    
                    // Loop through all search results and keep just the necessary data.
                    for i in 0 ..< items.count {
                        let snippetDict = (items[i] as Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
                        
                        // Gather the proper data depending on whether we're searching for channels or for videos.
                        if self.segDisplayedContent.selectedSegmentIndex == 0 {
                            // Keep the channel ID.
                            self.desiredChannelsArray.append(snippetDict["channelId"] as! String)
                        }
                        else {
                            // Create a new dictionary to store the video details.
                            var videoDetailsDict = Dictionary<String, AnyObject>()
                            videoDetailsDict["title"] = snippetDict["title"]
                            videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                            videoDetailsDict["videoID"] = (items[i]["id"] as! Dictionary<String, AnyObject>)["videoId"]
                            
                            // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                            self.videosArray.append(videoDetailsDict as [String : AnyObject])
   
                            self.tableView.reloadData()
                        }
                    }
                } catch {
                    print(error)
                }
                
                // Call the getChannelDetails(…) function to fetch the channels.
                if self.segDisplayedContent.selectedSegmentIndex == 0 {
                    self.getChannelDetails(true)
                }
                
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel videos: \(String(describing: error))")
            }
            
            // Hide the activity indicator.
            self.viewWait.isHidden = true
        })
        
        return true
    }
    
    // MARK: Custom method implementation
    func performGetRequest(_ targetURL: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: NSError?) -> Void) {
        
        var request = URLRequest(url: targetURL)
        request.httpMethod = "GET"
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { completion(data, (response as! HTTPURLResponse).statusCode, error as NSError?)
                
            }
        }
        
        task.resume()
        
    }

    func getChannelDetails(_ useChannelIDParam: Bool) {
        
        var urlString: String!
        if !useChannelIDParam {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }
        else {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }
        
        let targetURL = URL(string: urlString)
        
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error)  in
            if HTTPStatusCode == 200, error == nil {
                
                do {
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]

                    let items: AnyObject! = resultsDict["items"] as AnyObject
                    
                    let firstItemDict = (items as! Array<AnyObject>)[0] as! [String: AnyObject]

                    let snippetDict = firstItemDict["snippet"] as! [String: AnyObject]
 
                    var desiredValuesDict = [String: AnyObject]()
                    desiredValuesDict["title"] = snippetDict["title"]
                    desiredValuesDict["description"] = snippetDict["description"]
                
                    let thumbnailDict: [String: AnyObject]
                    thumbnailDict = snippetDict["thumbnails"] as! [String: AnyObject]
                    let defaultThumbnailDict = thumbnailDict["default"] as! [String: AnyObject]
                    
                    desiredValuesDict["thumbnail"] = defaultThumbnailDict["url"]

                    desiredValuesDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<String, AnyObject>)["relatedPlaylists"] as! Dictionary<String, AnyObject>)["uploads"]

                    self.channelsDataArray.append(desiredValuesDict as [String : AnyObject])

                    self.tableView.reloadData()
                    
                    // Load the next channel data (if exist).
                    self.channelIndex += 1
                    if self.channelIndex < self.desiredChannelsArray.count {
                        self.getChannelDetails(useChannelIDParam)
                    }
                    else {
                        self.viewWait.isHidden = true
                    }
                } catch {
                    print(error)
                }
                
            } else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(String(describing: error))")
            }
        })
    }
    
    func getVideosForChannelAtIndex(index: Int!) {
        //added &maxResults=10 to get 10 videos in statement below
        let playlistID = channelsDataArray[index]["playlistID"] as! String
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=20&playlistId=\(playlistID)&key=\(apiKey)"
        
        let targetURL = NSURL(string: urlString)
        
        performGetRequest(targetURL as URL?, completion: { (data, HTTPStatusCode, error)  in
            if HTTPStatusCode == 200, error == nil {
                do {
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
    
                    let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                    
                    for i in 0 ..< items.count {
                        let playlistSnippetDict = (items[i] as Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
                        
                        var desiredPlaylistItemDataDict = Dictionary<String, AnyObject>()
                        desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
                        desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                        desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<String, AnyObject>)["videoId"]
                        
                        self.videosArray.append(desiredPlaylistItemDataDict )
                        
                        self.tableView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel videos: \(String(describing: error))")
            }
            self.viewWait.isHidden = true
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "idSeguePlayer" {
            guard let playerViewController = segue.destination as? PlayerViewController else { return }
            playerViewController.videoID = videosArray[selectedVideoIndex]["videoID"] as? String
        }
    }
}
extension YouTubeController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segDisplayedContent.selectedSegmentIndex == 0 {
            segDisplayedContent.selectedSegmentIndex = 1
            viewWait.isHidden = false
            videosArray.removeAll(keepingCapacity: false)
            getVideosForChannelAtIndex(index: indexPath.row)
        }
        else {
            selectedVideoIndex = indexPath.row
            performSegue(withIdentifier: "idSeguePlayer", sender: self)
        }
    }
    
    // MARK: UITableView method implementation
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segDisplayedContent.selectedSegmentIndex == 0 {
            return channelsDataArray.count
        } else {
            return videosArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell!
        
        if segDisplayedContent.selectedSegmentIndex == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellChannel", for: indexPath)
            
            
            let channelTitleLabel = cell.viewWithTag(10) as! UILabel
            let channelDescriptionLabel = cell.viewWithTag(11) as! UILabel
            let thumbnailImageView = cell.viewWithTag(12) as! UIImageView
            
            if #available(iOS 13.0, *) {
                channelTitleLabel.textColor = .systemBlue
                channelDescriptionLabel.textColor = .label
            } else {
                // Fallback on earlier versions
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad  {
                channelDescriptionLabel.font = Font.Snapshot.cellLabel
            }
            
            let channelDetails = channelsDataArray[indexPath.row] as NSDictionary
            channelTitleLabel.text = channelDetails["title"] as? String
            channelDescriptionLabel.text = channelDetails["description"] as? String
            thumbnailImageView.image = UIImage(data: try! Data(contentsOf: URL(string: (channelDetails["thumbnail"] as? String)!)!))
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellVideo", for: indexPath)
            
            let videoTitle = cell.viewWithTag(10) as! UILabel
            let videoThumbnail = cell.viewWithTag(11) as! UIImageView
            
            if #available(iOS 13.0, *) {
                videoTitle.textColor = .label
            } else {
                // Fallback on earlier versions
            }
            
            let videoDetails = videosArray[indexPath.row] as NSDictionary
            videoTitle.text = videoDetails["title"] as? String
            videoTitle.numberOfLines = 2
            videoThumbnail.image = UIImage(data: try! Data(contentsOf: URL(string: (videoDetails["thumbnail"] as? String)!)!))
        }
        
        return cell
    }
}
extension YouTubeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
}
extension YouTubeController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {

    }
}
