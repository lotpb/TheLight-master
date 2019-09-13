  //
  //  DetailViewController.swift
  //  mySQLswift
  //
  //  Created by Peter Balsamo on 12/8/15.
  //  Copyright © 2015 Peter Balsamo. All rights reserved.
  //
  
  import UIKit
  import ReplayKit
  import UIKit
  import CoreLocation
  import CoreSpotlight //added CoreSpotlight
  import CoreBluetooth
  import MobileCoreServices //added CoreSpotlight
  
  
  final class DetailViewVC: UIViewController, RPPreviewViewControllerDelegate, AVSpeechSynthesizerDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, RPScreenRecorderDelegate {
    
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    
    let textviewText = "I know your works, that you are neither cold nor hot. I could wish you were cold or hot. So then, because you are lukewarm, and neither cold nor hot, I will vomit you out of My mouth."
    
    let languageList = ["Hindi", "Russian", "Greek", "United States", "United Kingdom", "Italy", "Israel", "Arabic", "China", "French", "German"]
    let languageCodeList = ["hi-IN", "ru-RU", "el-GR", "en-US", "en-GB", "it-IT", "he-IL", "ar-SA", "zh-CN", "fr-FR", "de-DE"]
    
    var langNum : Int!
    
    private let recorder = RPScreenRecorder.shared()
    private var locationManager = CLLocationManager()
    private let identifier = "com.TheLight" //added CoreSpotlight
    private let domainIdentifier = "com.lotpb.github.io/UnitedWebPage/index.html"
    private var activity: NSUserActivity!
    
    var activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    let languagePick: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    lazy var topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var middleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var pickView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var subject: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autocorrectionType = .yes
        textView.dataDetectorTypes = .all
        return textView
    }()
    
    lazy var pitch: UITextField = {
        let textField = UITextField()
        textField.text = "1.0"
        textField.keyboardAppearance = .dark
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var rate: UITextField = {
        let textField = UITextField()
        textField.text = "0.3"
        textField.keyboardAppearance = .dark
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var volume: UITextField = {
        let textField = UITextField()
        textField.text = "1.0"
        textField.keyboardAppearance = .dark
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let pitchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pitch"
        return label
    }()
    
    let rateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Rate"
        return label
    }()
    
    let volumeLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Volume"
        return label
    }()
    
    let latitudeLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Searching..."
        return label
    }()
    
    let longitudeLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Searching..."
        return label
    }()
    
    let altitudeLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Searching..."
        return label
    }()
    
    lazy var speakBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.setTitle("Speak", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.addTarget(self, action: #selector(speakingBtn), for: .touchUpInside)
        return button
    }()
    
    lazy var speechBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.setTitle("Speech", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.addTarget(self, action: #selector(speech), for: .touchUpInside)
        return button
    }()
    
    lazy var lightoffBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.setTitle("Light off", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Color.BlueColor
        button.addTarget(self, action: #selector(lightoff), for: .touchUpInside)
        return button
    }()
    
    lazy var spotlightBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.setTitle("Spotlight", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Color.BlueColor
        button.addTarget(self, action: #selector(AddItemToCoreSpotlight), for: .touchUpInside)
        return button
    }()
    
    lazy var nospotBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.setTitle("Spotlight off", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Color.BlueColor
        button.addTarget(self, action: #selector(RemoveItemFromCoreSpotlight), for: .touchUpInside)
        return button
    }()
    
    lazy var startRecordingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.setTitle("Start Recording", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue:1.0, alpha: 1.0)
        button.addTarget(self, action: #selector(startRecordingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var stopRecordingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.setTitle("Stop Recording", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(stopRecordingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = .init(x: 0, y: 0, width: 100, height: 32)
        if UIDevice.current.userInterfaceIdiom == .pad {
            button.setTitle("TheLight Software - Detail", for: .normal)
        } else {
            button.setTitle("Detail", for: .normal)
        }
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupNavigation()
        
        
        // MARK: - locationManager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        recorder.delegate = self
        activityIndicator.isHidden = true
        buttonEnabledControl(recorder.isRecording)
        
        langNum = 4
        languagePick.dataSource = self
        languagePick.delegate = self
        languagePick.selectRow(langNum, inComponent: 0, animated: true)
        
        setupFonts()
        self.subject.text = textviewText
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        self.tabBarController?.tabBar.isHidden = true
        //UIApplication.shared.isStatusBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigation() {
        
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 26)]
        self.navigationItem.largeTitleDisplayMode = .always
        
        let searchButton = UIBarButtonItem(title: "Light", style: .plain, target: self, action: #selector(lightcamera))
        let favButton = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [searchButton, favButton]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationItem.title = "TheLight - Detail"
        } else {
            navigationItem.title = "Detail"
        }
    }
    
    // MARK: - NavigationController Hidden
    
    @objc func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        self.navigationController?.setNavigationBarHidden(state, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.tabBarController?.hideTabBarAnimated(hide: state) //added
        }, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: false)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.lastContentOffset = scrollView.contentOffset.y;
    }
    
    func setupFonts() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.subject.font = Font.Detail.VtextAmount
            self.volume.font = Font.Detail.VtextAmount
            self.pitch.font = Font.Detail.VtextAmount
            self.rate.font = Font.Detail.VtextAmount
            self.pitchLabel.font = Font.Detail.VtextAmount
            self.rateLabel.font = Font.Detail.VtextAmount
            self.volumeLabel.font = Font.Detail.VtextAmount
            self.latitudeLabel.font = Font.Detail.VtextAmount
            self.longitudeLabel.font = Font.Detail.VtextAmount
            self.speechBtn.titleLabel?.font = Font.Detail.VtextAmount
            self.speakBtn.titleLabel?.font = Font.Detail.VtextAmount
            self.lightoffBtn.titleLabel?.font = Font.Detail.textdate
            self.spotlightBtn.titleLabel?.font = Font.Detail.textdate
            self.nospotBtn.titleLabel?.font = Font.Detail.textdate
            self.altitudeLabel.font = Font.Detail.VtextAmount
        } else {
            self.subject.font = Font.Detail.textdate
            self.volume.font = Font.Detail.textdate
            self.pitch.font = Font.Detail.textdate
            self.rate.font = Font.Detail.textdate
            self.pitchLabel.font = Font.Detail.textdate
            self.rateLabel.font = Font.Detail.textdate
            self.volumeLabel.font = Font.Detail.textdate
            self.latitudeLabel.font = Font.Detail.textdate
            self.longitudeLabel.font = Font.Detail.textdate
            self.speechBtn.titleLabel?.font = Font.Detail.textdate
            self.speakBtn.titleLabel?.font = Font.Detail.textdate
            self.lightoffBtn.titleLabel?.font = Font.Detail.textdate
            self.spotlightBtn.titleLabel?.font = Font.Detail.textdate
            self.nospotBtn.titleLabel?.font = Font.Detail.textdate
            self.altitudeLabel.font = Font.Detail.textdate
        }
    }
    
    func setupViews() {
        
        view.addSubview(topView)
        topView.addSubview(subject)
        topView.addSubview(speakBtn)
        topView.addSubview(speechBtn)
        view.addSubview(middleView)
        middleView.addSubview(pitch)
        middleView.addSubview(rate)
        middleView.addSubview(volume)
        middleView.addSubview(lightoffBtn)
        middleView.addSubview(spotlightBtn)
        middleView.addSubview(nospotBtn)
        middleView.addSubview(pitchLabel)
        middleView.addSubview(rateLabel)
        middleView.addSubview(volumeLabel)
        middleView.addSubview(latitudeLabel)
        middleView.addSubview(longitudeLabel)
        middleView.addSubview(altitudeLabel)
        middleView.addSubview(startRecordingButton)
        middleView.addSubview(stopRecordingButton)
        view.addSubview(pickView)
        pickView.addSubview(languagePick)
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            topView.heightAnchor.constraint(equalToConstant: 150),
            
            subject.topAnchor.constraint(equalTo: topView.topAnchor, constant: 15),
            subject.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
            subject.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            subject.heightAnchor.constraint(equalToConstant: 90),
            
            speakBtn.topAnchor.constraint(equalTo: subject.bottomAnchor, constant: 10),
            speakBtn.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
            speakBtn.widthAnchor.constraint(equalToConstant: 85),
            speakBtn.heightAnchor.constraint(equalToConstant: 32),
            
            speechBtn.topAnchor.constraint(equalTo: subject.bottomAnchor, constant: 10),
            speechBtn.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            speechBtn.widthAnchor.constraint(equalToConstant: 85),
            speechBtn.heightAnchor.constraint(equalToConstant: 32),
            
            middleView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0),
            middleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            middleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            middleView.heightAnchor.constraint(equalToConstant: 285),
            
            pitch.topAnchor.constraint(equalTo: middleView.topAnchor, constant: 20),
            pitch.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 18),
            pitch.widthAnchor.constraint(equalToConstant: 45),
            pitch.heightAnchor.constraint(equalToConstant: 30),
            
            rate.topAnchor.constraint(equalTo: pitch.bottomAnchor, constant: 20),
            rate.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 18),
            rate.widthAnchor.constraint(equalToConstant: 45),
            rate.heightAnchor.constraint(equalToConstant: 30),
            
            volume.topAnchor.constraint(equalTo: rate.bottomAnchor, constant: 20),
            volume.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 18),
            volume.widthAnchor.constraint(equalToConstant: 45),
            volume.heightAnchor.constraint(equalToConstant: 30),
            
            lightoffBtn.topAnchor.constraint(equalTo: middleView.topAnchor, constant: 20),
            lightoffBtn.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            lightoffBtn.widthAnchor.constraint(equalToConstant: 100),
            lightoffBtn.heightAnchor.constraint(equalToConstant: 30),
            
            spotlightBtn.topAnchor.constraint(equalTo: lightoffBtn.bottomAnchor, constant: 20),
            spotlightBtn.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            spotlightBtn.widthAnchor.constraint(equalToConstant: 100),
            spotlightBtn.heightAnchor.constraint(equalToConstant: 30),
            
            nospotBtn.topAnchor.constraint(equalTo: spotlightBtn.bottomAnchor, constant: 20),
            nospotBtn.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            nospotBtn.widthAnchor.constraint(equalToConstant: 100),
            nospotBtn.heightAnchor.constraint(equalToConstant: 30),
            
            pitchLabel.topAnchor.constraint(equalTo: middleView.topAnchor, constant: 20),
            pitchLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 80),
            pitchLabel.heightAnchor.constraint(equalToConstant: 30),
            
            rateLabel.topAnchor.constraint(equalTo: pitch.bottomAnchor, constant: 20),
            rateLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 80),
            rateLabel.heightAnchor.constraint(equalToConstant: 30),
            
            volumeLabel.topAnchor.constraint(equalTo: rate.bottomAnchor, constant: 20),
            volumeLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 80),
            volumeLabel.heightAnchor.constraint(equalToConstant: 30),
            
            latitudeLabel.topAnchor.constraint(equalTo: volume.bottomAnchor, constant: 10),
            latitudeLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 18),
            latitudeLabel.heightAnchor.constraint(equalToConstant: 21),
            
            longitudeLabel.topAnchor.constraint(equalTo: latitudeLabel.bottomAnchor, constant: 10),
            longitudeLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 18),
            longitudeLabel.heightAnchor.constraint(equalToConstant: 21),
            
            altitudeLabel.topAnchor.constraint(equalTo: nospotBtn.bottomAnchor, constant: 10),
            altitudeLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            altitudeLabel.heightAnchor.constraint(equalToConstant: 21),
            
            startRecordingButton.topAnchor.constraint(equalTo: longitudeLabel.bottomAnchor, constant: 10),
            startRecordingButton.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 18),
            startRecordingButton.widthAnchor.constraint(equalToConstant: 150),
            startRecordingButton.heightAnchor.constraint(equalToConstant: 50),
            
            stopRecordingButton.topAnchor.constraint(equalTo: longitudeLabel.bottomAnchor, constant: 10),
            stopRecordingButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            stopRecordingButton.widthAnchor.constraint(equalToConstant: 150),
            stopRecordingButton.heightAnchor.constraint(equalToConstant: 50),
            
            pickView.topAnchor.constraint(equalTo: middleView.bottomAnchor, constant: 0),
            pickView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            pickView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            pickView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            languagePick.topAnchor.constraint(equalTo: pickView.topAnchor, constant: 10),
            languagePick.centerXAnchor.constraint(equalTo: pickView.centerXAnchor),
            languagePick.centerYAnchor.constraint(equalTo: pickView.centerYAnchor)
            ])
    }
    
    // MARK: - CoreSpotlight
    @IBAction func AddItemToCoreSpotlight(_ sender: AnyObject) {
        
        let activityType = String(format: "%@.%@", identifier, domainIdentifier)
        activity = NSUserActivity(activityType: activityType)
        activity.title = "TheLight"
        activity.keywords = Set<String>(arrayLiteral: "window", "door", "siding", "roof")
        activity.isEligibleForSearch = true
        activity.becomeCurrent()
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = "TheLight"
        attributeSet.contentDescription = "CoreSpotLight tutorial"
        attributeSet.keywords = ["window", "door", "siding", "roof"]
        //let image = UIImage(named: "m7")!
        //let data = UIImagePNGRepresentation(image)
        //attributeSet.thumbnailData = data
        
        let item = CSSearchableItem(
            uniqueIdentifier: identifier,
            domainIdentifier: domainIdentifier,
            attributeSet: attributeSet)
        
        CSSearchableIndex.default().indexSearchableItems([item]) { (error: Error?) in
            if let error =  error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed")
            }
        }
    }
    
    @IBAction func RemoveItemFromCoreSpotlight(_ sender: AnyObject) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [identifier])
        { (error: Error?) in
            if let error = error {
                print("Remove error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed")
            }
        }
    }
    
    // MARK: - ScreenRecorderDelegate
    @IBAction func startRecordingButtonTapped(_ sender: AnyObject) {
        
        activityIndicator.isHidden = false
        recorder.isMicrophoneEnabled = true
        recorder.startRecording{ [unowned self] (error) in
            
            guard error == nil else {
                print("There was an error starting the recording.")
                return
            }
            
            DispatchQueue.main.async { [unowned self] in
                self.activityIndicator.isHidden = true
            }
            
            NSLog("Start recording")
            self.buttonEnabledControl(true)
        }
    }
    
    @IBAction func stopRecordingButtonTapped(_ sender: AnyObject) {
        
        activityIndicator.isHidden = false
        
        // end recording
        recorder.stopRecording(handler: { [unowned self] (previewViewController, error) in
            DispatchQueue.main.async { [unowned self] in
                self.activityIndicator.isHidden = true
            }
            
            self.buttonEnabledControl(false)
            
            if let error = error {
                NSLog("Failed stop recording: \(error.localizedDescription)")
                return
            }
            
            NSLog("Stop recording")
            previewViewController?.previewControllerDelegate = self
            
            DispatchQueue.main.async { [unowned self] in
                // show preview window
                self.present(previewViewController!, animated: true)
            }
        })
    }
    
    private func buttonEnabledControl(_ isRecording: Bool) {
        DispatchQueue.main.async { [unowned self] in
            let enebledColor = Color.BlueColor
            let disabledColor = UIColor.lightGray
            
            if !self.recorder.isAvailable {
                self.startRecordingButton.isEnabled = false
                self.startRecordingButton.backgroundColor = disabledColor
                self.stopRecordingButton.isEnabled = false
                self.stopRecordingButton.backgroundColor = disabledColor
                
                return
            }
            
            self.startRecordingButton.isEnabled = !isRecording
            self.startRecordingButton.backgroundColor = isRecording ? disabledColor : enebledColor
            self.stopRecordingButton.isEnabled = isRecording
            self.stopRecordingButton.backgroundColor = isRecording ? enebledColor : disabledColor
        }
    }
    
    // called after stopping the recording
    func screenRecorder(_ screenRecorder: RPScreenRecorder, didStopRecordingWithError error: Error, previewViewController: RPPreviewViewController?) {
        NSLog("Stop recording")
    }
    
    // called when the recorder availability has changed
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        let availability = screenRecorder.isAvailable
        NSLog("Availablility: \(availability)")
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        NSLog("Preview finish")
        
        DispatchQueue.main.async { [unowned previewController] in
            // close preview window
            previewController.dismiss(animated: true)
        }
    }
    
    // MARK: - camera light
    @objc func lightcamera() {
        toggleTorch(on: true)
        
    }
    
    @IBAction func lightoff(_ sender: AnyObject) {
        toggleTorch(on: false)
        
    }
    
    func toggleTorch(on: Bool) {
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            self.simpleAlert(title: "Alert!", message: "Torch is not available")
        }
    }
    
    // MARK: - speech
    @objc func speech(_ sender: AnyObject) {
        
        //"The words of King Solomon the wisest of men. For i found one righteous man in a thousand and not one righteous woman"
        //"Hello world!!! my name is Peter Balsamo")
        //"Hello world!!! It's time too kiss the feet of Peter Balsamo"
        let utterance = AVSpeechUtterance(string: "The words of King Solomon the wisest of men. For i found one righteous man in a thousand, and not one righteous woman")
        //utterance.voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCodeList[langNum])
        utterance.rate = 0.4
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    // MARK: - Speak red text
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: characterRange)
        subject.attributedText = mutableAttributedString
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        subject.attributedText = NSAttributedString(string: utterance.speechString)
    }
    
    @IBAction func speakingBtn(_ sender: AnyObject) {
        let string = subject.text
        let utterance = AVSpeechUtterance(string: string!)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCodeList[langNum])
        utterance.rate = 0.4 //langRate
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        synthesizer.speak(utterance)
    }
    
    // MARK:  Pickerview
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return languageList.count 
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return languageList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        langNum = row
    }
    
    // MARK: - locationManager
    func locationManager(_ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            latitudeLabel.text = String(format: "Lat: %.4f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "Lon: %.4f", location.coordinate.longitude)
            altitudeLabel.text = String(format: "Alt: %.2f", location.altitude)
            
            latitudeLabel.textColor = Color.twitterBlue
            longitudeLabel.textColor = Color.twitterBlue
            altitudeLabel.textColor = Color.twitterBlue
        }
    }
    
    func locationManager(_ locationManager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
  }

