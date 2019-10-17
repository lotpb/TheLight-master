 //
//  CodeGenController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 12/28/15.
//  Copyright © 2015 Peter Balsamo. All rights reserved.
//

import UIKit
import AVFoundation
import Parse
import FirebaseDatabase
import FirebaseAuth


@available(iOS 13.0, *)
final class CodeGenVC: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var slider: UISlider!
    
    var qrcodeImage: CIImage!
    var defaults = UserDefaults.standard
    
    let imageProfile: CustomImageView = {
        let imageView = CustomImageView()
        imageView.backgroundColor = .systemGray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var generateBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.setTitle("Generate", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.addTarget(self, action: #selector(performButtonAction), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        //self.extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = .secondarySystemGroupedBackground

        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            let query:PFQuery = PFUser.query()!
            query.whereKey("username",  equalTo:defaults.string(forKey: "usernameKey")!)
            query.limit = 1
            query.cachePolicy = .cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                if error == nil {
                    if let imageFile = object!.object(forKey: "imageFile") as? PFFileObject {
                        imageFile.getDataInBackground { imageData, error in
                            self.imageProfile.image = UIImage(data: imageData!)
                        }
                    }
                }
            }
        } else {
            //firebase
            guard let uid = Auth.auth().currentUser?.uid else {return}
            FirebaseRef.databaseRoot.child("users")
                .queryOrdered(byChild: "uid")
                .queryEqual(toValue: uid)
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    for snap in snapshot.children {
                        let userSnap = snap as! DataSnapshot
                        let userDict = userSnap.value as! [String: Any]
                        let blogImageUrl = userDict["profileImageUrl"] as? String
                        self.imageProfile.loadImage(urlString: blogImageUrl!)
                    }
                })
        }
        
        self.textField!.font = Font.celltitle18m
        self.textField!.text = defaults.string(forKey: "usernameKey")
        
        slider.minimumTrackTintColor = .systemOrange
        slider.thumbTintColor = .systemOrange
        
        setupNavigation()
        setupForm()
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
    
    func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let addBtn = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(newDataBtn))
        navigationItem.rightBarButtonItems = [addBtn]
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(self.handleLogout))
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - Membership"
        } else {
            navigationItem.title = "Membership"
        }
    }
    
    func setupForm() {
        
        view.addSubview(self.imageProfile)
        view.addSubview(self.generateBtn)
        
        NSLayoutConstraint.activate([
            self.imageProfile.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
            self.imageProfile.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            self.imageProfile.widthAnchor.constraint(equalToConstant: 85),
            self.imageProfile.heightAnchor.constraint(equalToConstant: 85),
            
            self.generateBtn.topAnchor.constraint(equalTo: textField.topAnchor, constant: 50),
            self.generateBtn.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            self.generateBtn.widthAnchor.constraint(equalToConstant: 85),
            self.generateBtn.heightAnchor.constraint(equalToConstant: 32)
            ])
    }
    
    // MARK: - Button
    @objc func newDataBtn() {
        self.performSegue(withIdentifier: "QRScannerSegue", sender: self)
    }

    
    @IBAction func performButtonAction(_ sender: AnyObject) {
        if qrcodeImage == nil {
            if textField.text == "" {
                return
            }
            
            let data = textField.text!.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator") //CIPDF417BarcodeGenerator
            filter!.setValue(data, forKey: "inputMessage")
            filter!.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter!.outputImage
            textField.resignFirstResponder()
            generateBtn.setTitle("Clear", for: .normal)
            
            displayQRCodeImage()
        }
        else {
            imgQRCode.image = nil
            qrcodeImage = nil
            generateBtn.setTitle("Generate", for: .normal)
        }
        textField.isEnabled = !textField.isEnabled
        slider.isHidden = !slider.isHidden
    }
    
    
    @IBAction func changeImageViewScale(_ sender: AnyObject) {
        imgQRCode.transform = CGAffineTransform(scaleX: CGFloat(slider.value), y: CGFloat(slider.value))
    }
    
    // MARK: Custom method implementation
    func displayQRCodeImage() {
        
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        imgQRCode.image = UIImage(ciImage: transformedImage)
    }
    
    // MARK: - generateQRCodeFromString
    func generateQRCodeFromString(_ string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.isoLatin1)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    // MARK: - generatePDF417BarcodeFromString
    func generatePDF417BarcodeFromString(_ string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.isoLatin1)
        
        if let filter = CIFilter(name: "CIPDF417BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
