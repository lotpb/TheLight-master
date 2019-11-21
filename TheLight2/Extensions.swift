//
//  Constants.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 2/9/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

// MARK:, // TODO: and // FIXME:
import UIKit

var searchController: UISearchController!

enum Config {
    static let NewsLead = "Company to expand to a new web advertising directive this week."
    static let NewsCust = "Check out or new line of fabulous windows and siding."
    static let NewsVend = "Peter Balsamo Appointed to United's Board of Directors."
    static let NewsEmploy = "Health benifits cancelled immediately, starting today."
    static let BaseUrl = "http://lotpb.github.io/UnitedWebPage/index.html"
}

enum Color {
    static let BlueColor = #colorLiteral(red: 0.2039215686, green: 0.4823529412, blue: 0.968627451, alpha: 1)  //UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha: 1.0)
    static let DGrayColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) //UIColor(white:0.45, alpha:1.0)
    static let LGrayColor = UIColor(white:0.90, alpha:1.0)
    static let DGreenColor = #colorLiteral(red: 0.2862745098, green: 0.5294117647, blue: 0.1960784314, alpha: 1) //UIColor(red:0.16, green:0.54, blue:0.13, alpha: 1.0)
    static let youtubeRed = UIColor.rgb(red: 230, green: 32, blue: 31)
    static let twitterBlue = UIColor.rgb(red: 61, green: 167, blue: 244)
    static let twitterText = UIColor(red:0.54, green:0.60, blue:0.65, alpha: 1.0)
    static let twitterline = UIColor.rgb(red: 230, green: 230, blue: 230)
    //static let facebookBlue = UIColor.rgb(red: 0, green: 137, blue: 249)
    static let goldColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)  //UIColor(red:0.76, green:0.57, blue:0.27, alpha: 1.0)
    static let toolbarColor = #colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 1)
    
    enum Header {
        static let headtextColor = Color.goldColor
    }
    
    enum Blog {
        static let navColor = Color.twitterBlue
        //static let borderbtnColor = Color.LGrayColor.cgColor
        static let borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //Color.goldColor
        static let buttonColor = Color.twitterBlue
        static let weblinkText = Color.twitterBlue
        static let emaillinkText = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        static let phonelinkText = UIColor.systemGreen
    }
    enum Lead {
        static let navColor = #colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)
        static let labelColor = Color.DGrayColor
        static let labelColor1 = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        static let buttonColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    }
    
    enum Cust {
        static let navColor = UIColor.black
        static let labelColor = Color.DGrayColor
        static let labelColor1 = Color.BlueColor
        static let buttonColor = Color.BlueColor
    }
    
    enum Vend {
        static let navColor = UIColor.black
        static let labelColor = UIColor(red: 0.56, green: 0.45, blue: 0.62, alpha: 1.0)
        static let buttonColor = UIColor(red: 0.56, green: 0.45, blue: 0.62, alpha: 1.0)
    }
    
    enum Employ {
        static let navColor = UIColor.black
        static let labelColor = UIColor(red: 0.64, green: 0.54, blue: 0.50, alpha: 1.0)
        static let buttonColor = UIColor(red: 0.64, green: 0.54, blue: 0.50, alpha: 1.0)
    }
    
    enum Mile {
        static let collectColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //UIColor(white:0.25, alpha:1.0)
        static let cellColor = UIColor(white:0.97, alpha:1.0)
        static let cellborderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        static let toolbarColor = UIColor(white:0.95, alpha:1.0)
        //static let toolColor = #colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 1)
        //static let textColor1 = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        static let calenderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        static let borderColor = UIColor(white:0.90, alpha:1.0)
    }
    
    enum News {
        static let navColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //Color.youtubeRed
        static let buttonColor = Color.BlueColor
    }
    
    enum Stat {
        static let navColor = #colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1) //UIColor.red
    }
    
    enum Snap {
        static let tablebackColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        static let collectbackColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //UIColor(white:0.25, alpha:1.0)
        static let textColor = #colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 1)
        static let textColor1 = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        static let lineColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)//#colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 1)
    }
    
    enum Table {
        static let navColor = #colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)
        static let labelColor = UIColor(red: 0.28, green: 0.50, blue: 0.49, alpha: 1.0)
        //static let labelColor = UIColor(red: 0.65, green: 0.49, blue: 0.35, alpha: 1.0)
    }
}

struct Font {
    
    static let celltitle40r = UIFont.systemFont(ofSize: 40)
    
    static let celltitle36r = UIFont.systemFont(ofSize: 36)
    
    static let celltitle30r = UIFont.systemFont(ofSize: 30)
    static let celltitle30l = UIFont.systemFont(ofSize: 30, weight: .light)
    static let celltitle30b = UIFont.systemFont(ofSize: 30, weight: .bold)
    
    static let navlabel = UIFont(name: "HelveticaNeue-Thin", size: 25.0)
    
    static let celltitle26r = UIFont.systemFont(ofSize: 26)
    static let celltitle26l = UIFont.systemFont(ofSize: 26, weight: .light)
    
    static let celltitle24l = UIFont.systemFont(ofSize: 24, weight: .light)
    
    static let celltitle22b = UIFont.boldSystemFont(ofSize: 22)
    static let celltitle22m = UIFont.systemFont(ofSize: 22, weight: .medium)
    static let celltitle22r = UIFont.systemFont(ofSize: 22)
    static let celltitle22l = UIFont.systemFont(ofSize: 22, weight: .light)
    
    static let celltitle20b = UIFont.boldSystemFont(ofSize: 20)
    static let celltitle20m = UIFont.systemFont(ofSize: 20, weight: .medium)
    static let celltitle20r = UIFont.systemFont(ofSize: 20)
    static let celltitle20l = UIFont.systemFont(ofSize: 20, weight: .light)
    
    static let celltitle18b = UIFont.boldSystemFont(ofSize: 18)
    static let celltitle18m = UIFont.systemFont(ofSize: 18, weight: .medium)
    static let celltitle18r = UIFont.systemFont(ofSize: 18)
    static let celltitle18l = UIFont.systemFont(ofSize: 18, weight: .light)
    
    static let celltitle16b = UIFont.boldSystemFont(ofSize: 16)
    static let celltitle16m = UIFont.systemFont(ofSize: 16, weight: .medium)
    static let celltitle16r = UIFont.systemFont(ofSize: 16)
    static let celltitle16l = UIFont.systemFont(ofSize: 16, weight: .light)
    
    static let celltitle14m = UIFont.systemFont(ofSize: 14, weight: .medium)
    static let celltitle14r = UIFont.systemFont(ofSize: 14)
    static let celltitle14l = UIFont.systemFont(ofSize: 14, weight: .light)
    
    static let celltitle12b = UIFont.boldSystemFont(ofSize: 12)
    static let celltitle12m = UIFont.systemFont(ofSize: 12, weight: .medium)
    static let celltitle12r = UIFont.systemFont(ofSize: 12)
    static let celltitle12l = UIFont.systemFont(ofSize: 12, weight: .light)
    
    struct Blog {
        
        static let celltitlePad = Font.celltitle22m
        static let cellsubtitlePad = Font.celltitle22r
        static let celldatePad = Font.celltitle18l
        
        static let celltitle = celltitle18b
        static let celldate = Font.celltitle16r
        static let cellLabel = celltitle18b
        static let cellsubject = Font.celltitle20l
    }
    
    struct BlogEdit {
        static let replytitlePad = celltitle18b
        static let replysubtitlePad = Font.celltitle18l
        
        static let replytitle = Font.celltitle16b
        static let replysubtitle = Font.celltitle16l
    }
    
    struct News {
        static let newstitlePad = celltitle26r
        static let newssourcePad = Font.celltitle20r
        static let newslabel1Pad = celltitle18b
        static let newslabel2Pad = Font.celltitle18r
        
        static let newstitle = Font.celltitle18l
        static let newssource = Font.celltitle14l
        static let newslabel1 = celltitle16b
        static let newslabel2 = Font.celltitle14l
    }
    
    struct Snapshot {
        static let celltitlePad = celltitle26l
        static let cellsubtitlePad = celltitle20r
        static let cellgallery = Font.celltitle16l
        static let cellLabel = celltitle14r
    }
    
    struct Stat {
        static let celltitlePad = celltitle20m
    }
    
    struct Detail {
        static let ipadname = celltitle30l
        static let ipadAmount = celltitle40r
        static let ipaddate = Font.celltitle18r
        static let ipadaddress = celltitle26l
        
        static let textname = celltitle24l
        static let textdate = Font.celltitle16r
        static let textaddress = Font.celltitle20r
        static let textAmount = celltitle30r
        
        static let Vtextname = Font.celltitle18l
        static let Vtextdate = Font.celltitle12r
        static let VtextAmount = celltitle20m
        
        static let celltitlePad = celltitle16b
        static let cellsubtitlePad = Font.celltitle16l
        static let celltitle = celltitle12b
        static let cellsubtitle = Font.celltitle12l
        
        static let ipadnewstitle = celltitle20b
        static let ipadnewssubtitle = Font.celltitle18l
        static let ipadnewsdetail = Font.celltitle18r
        
        static let newstitle = celltitle18b
        static let newssubtitle = Font.celltitle16l
        static let newsdetail = Font.celltitle16r
        
        static let textbutton = Font.celltitle18r
    }
}

//declared in News search
func requestSuggestionsURL(text: String) -> URL {
    let netText = text.addingPercentEncoding(withAllowedCharacters: CharacterSet())!
    let url = URL.init(string: "https://api.bing.com/osjson.aspx?query=\(netText)")!
    return url
}

//declared in CollectionViewCell
var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastUrlUsedToLoadImage: String?
    
    func loadImage(urlString: String){
        guard let url = URL(string: urlString) else {return}
        
        lastUrlUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cacheImage = imageCache[urlString]{
            self.image = cacheImage
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fetch post image:", err)
                return
            }
            //stops loading duplicate image load
            if url.absoluteString != self.lastUrlUsedToLoadImage {
                return
            }
            
            guard let imageData = data else {return}
            let photoImage = UIImage(data: imageData)
            
            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                self.image = photoImage ?? #imageLiteral(resourceName: "profile-rabbit-toy")
            }
            }.resume()
    }
}

// MARK: - PlayVC, NavVC
enum stateOfVC {
    case minimized
    case fullScreen
    case hidden
}

enum Direction {
    case up
    case left
    case none
}

public extension String {
    
    var isValidEmailAddress: Bool { //valid email Valid
        let types: NSTextCheckingResult.CheckingType = [.link]
        let linkDetector = try? NSDataDetector(types: types.rawValue)
        let range = NSRange(location: 0, length: self.count)
        let result = linkDetector?.firstMatch(in: self, options: .reportCompletion, range: range)
        let scheme = result?.url?.scheme ?? ""
        return scheme == "mailto" && result?.range.length == self.count
    }
    // MARK: - begin and ends RemoveWhiteSpace  //EditData
    func removeWhiteSpace() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    // MARK: - all RemoveWhiteSpace  //BlogEdit
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

// MARK: - AlertController
public extension UIViewController {
    
    func simpleAlert(title:String?, message:String?) { //withTitle:
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
}

//--------------News youtube------------
extension UIColor { //youtube red
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

// UIImage with downloadable content
extension UIImage {
    class  func contentOfURL(link: String) -> UIImage {
        let url = URL.init(string: link)!
        var image = UIImage()
        do {
            let data = try Data.init(contentsOf: url)
            image = UIImage.init(data: data)!
        } catch _ {
            print("error downloading images")
        }
        return image
    }
}

extension UIView {

    ///testTable
    func pin(to superView: UIView) {
        translatesAutoresizingMaskIntoConstraints                              = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive            = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive    = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive  = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive      = true
    }

    //News - youtube
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    //SharePhotoController
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right:NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

// MARK: - Scroll to top TableView
extension UITableView { // MusicController
    func scrollToTop(animated: Bool) {
        setContentOffset(.zero, animated: animated)
    }
}

// MARK: - detect a URL in a String using NSDataDetector
extension NSRange {
    //NSRange rather than a Swift string range.
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        
        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
        
        return fromIndex ..< toIndex
    }
}

//------------------------------------

extension UISplitViewController: UISplitViewControllerDelegate {
    
    open override func viewDidLoad() { // FIX - remove bottom bar
        self.extendedLayoutIncludesOpaqueBars = true
    }
} 

extension UITabBarController {
    /*
    func increaseBadge(indexOfTab: Int, num: String) {
        let tabItem = tabBar.items![indexOfTab]
        tabItem.badgeValue = num
    } */
    
    //hide TabBar
    func hideTabBarAnimated(hide:Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            if hide {
                self.tabBar.transform = CGAffineTransform(translationX: 0, y: 50)
            } else {
                self.tabBar.transform = CGAffineTransform.identity
            }
        })
    }
}

extension Date {
    
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
    }
}


