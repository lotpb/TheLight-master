//
//  CardViewController.swift
//  CardViewAnimation
//
//  Created by Brian Advent on 26.10.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit


class CardViewController: UIViewController {

    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!

    private var homeController: GeotificationVC?

    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let centerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let driveView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let promoView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let toolbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let promoBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "cloud.sun.fill")?
                            .withRenderingMode(.alwaysOriginal), for:.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let driveBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "cloud.sun.rain.fill")?
                            .withRenderingMode(.alwaysOriginal), for:.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let searchBtn: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        let boldFont = UIFont.boldSystemFont(ofSize: 24)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)
        button.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: configuration), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let optionBtn: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        let boldFont = UIFont.boldSystemFont(ofSize: 24)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)
        button.setImage(UIImage(systemName: "slider.horizontal.3", withConfiguration: configuration), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    public let chevronBtn: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        let boldFont = UIFont.boldSystemFont(ofSize: 20)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)
        button.setImage(UIImage(systemName: "chevron.compact.up", withConfiguration: configuration), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    public let listBtn: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        let boldFont = UIFont.boldSystemFont(ofSize: 20)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)
        button.setImage(UIImage(systemName: "list.bullet", withConfiguration: configuration), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let offLineBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemOrange
        button.tintColor = .white
        let boldFont = UIFont.boldSystemFont(ofSize: 24)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)
        button.setImage(UIImage(systemName: "hand.raised.fill", withConfiguration: configuration), for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let offlineLabel: UILabel = {
        let label = UILabel()
        label.text = "GO OFFLINE"
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let promoLabel: UILabel = {
        let label = UILabel()
        label.text = "See upcoming promotions"
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let driveLabel: UILabel = {
        let label = UILabel()
        label.text = "See driving time"
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let centerTLabel: UILabel = {
        let label = UILabel()
        label.text = "◆ Promotion"
        label.font = Font.celltitle12r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let centerLabel: UILabel = {
        let label = UILabel()
        label.text = "Complete 48 trips for $130 extra"
        label.font = Font.celltitle26r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let centerBLabel: UILabel = {
        let label = UILabel()
        label.text = "Quest ends Monday 4:00 AM"
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemFill
        titleLabel.textColor = .label
        floatButton()
    }

    private func floatButton() {
        let btnLayer2: CALayer = offLineBtn.layer
        btnLayer2.cornerRadius = 76 / 2
        btnLayer2.masksToBounds = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.addSubview(mainView)
        mainView.addSubview(topView)
        mainView.addSubview(centerView)
        mainView.addSubview(driveView)
        mainView.addSubview(promoView)
        mainView.addSubview(toolbarView)
        mainView.addSubview(promoLabel)
        mainView.addSubview(driveLabel)
        mainView.addSubview(promoBtn)
        mainView.addSubview(driveBtn)
        mainView.addSubview(segmentedControl)
        mainView.addSubview(centerTLabel)
        mainView.addSubview(centerLabel)
        mainView.addSubview(centerBLabel)

        view.addSubview(offLineBtn)
        view.addSubview(searchBtn)
        view.addSubview(optionBtn)
        view.addSubview(chevronBtn)
        view.addSubview(listBtn)
        view.addSubview(offlineLabel)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([

            chevronBtn.topAnchor.constraint(equalTo: handleArea.topAnchor, constant: 15),
            chevronBtn.leadingAnchor.constraint(equalTo: handleArea.leadingAnchor, constant: 20),
            chevronBtn.widthAnchor.constraint(equalToConstant: 40),
            chevronBtn.heightAnchor.constraint(equalToConstant: 40),

            listBtn.topAnchor.constraint(equalTo: handleArea.topAnchor, constant: 15),
            listBtn.trailingAnchor.constraint(equalTo: handleArea.trailingAnchor, constant: -20),
            listBtn.widthAnchor.constraint(equalToConstant: 40),
            listBtn.heightAnchor.constraint(equalToConstant: 40),

            mainView.topAnchor.constraint(equalTo: handleArea.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            topView.topAnchor.constraint(equalTo: mainView.topAnchor),
            topView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 80),

            segmentedControl.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),
            segmentedControl.widthAnchor.constraint(equalToConstant: 325),

            centerView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 10),
            centerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            centerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10),
            centerView.heightAnchor.constraint(equalToConstant: 110),

            centerTLabel.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 10),
            centerTLabel.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 15),
            centerLabel.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 15),
            centerLabel.centerYAnchor.constraint(equalTo: centerView.centerYAnchor),
            centerBLabel.topAnchor.constraint(equalTo: centerLabel.bottomAnchor, constant: 2),
            centerBLabel.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: 15),

            promoView.topAnchor.constraint(equalTo: centerView.bottomAnchor, constant: 10),
            promoView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            promoView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10),
            promoView.heightAnchor.constraint(equalToConstant: 60),

            driveView.topAnchor.constraint(equalTo: promoView.bottomAnchor, constant: 10),
            driveView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            driveView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10),
            driveView.heightAnchor.constraint(equalToConstant: 60),

            toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toolbarView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 125),

            promoBtn.leadingAnchor.constraint(equalTo: promoView.leadingAnchor, constant: 10),
            promoBtn.heightAnchor.constraint(equalToConstant: 30),
            promoBtn.centerYAnchor.constraint(equalTo: promoView.centerYAnchor),

            driveBtn.leadingAnchor.constraint(equalTo: driveView.leadingAnchor, constant: 10),
            driveBtn.heightAnchor.constraint(equalToConstant: 30),
            driveBtn.centerYAnchor.constraint(equalTo: driveView.centerYAnchor),

            promoLabel.leftAnchor.constraint(equalTo: promoBtn.rightAnchor, constant: 10),
            promoLabel.centerYAnchor.constraint(equalTo: promoView.centerYAnchor),

            driveLabel.leftAnchor.constraint(equalTo: driveBtn.rightAnchor, constant: 10),
            driveLabel.centerYAnchor.constraint(equalTo: driveView.centerYAnchor),

            searchBtn.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 30),
            searchBtn.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 30),
            searchBtn.widthAnchor.constraint(equalToConstant: 40),
            searchBtn.heightAnchor.constraint(equalToConstant: 40),

            optionBtn.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 30),
            optionBtn.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -30),
            optionBtn.widthAnchor.constraint(equalToConstant: 40),
            optionBtn.heightAnchor.constraint(equalToConstant: 40),

            offLineBtn.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            offLineBtn.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 10),
            offLineBtn.widthAnchor.constraint(equalToConstant: 76),
            offLineBtn.heightAnchor.constraint(equalToConstant: 76),

            offlineLabel.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 91),
            offlineLabel.centerXAnchor.constraint(equalTo: offLineBtn.centerXAnchor),
            offlineLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    // MARK: - SegmentedControl
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: break;

        case 1:
            segmentedControl.selectedSegmentIndex = 1
            self.homeController?.openRegion() // FIXME:

        case 2:
            segmentedControl.selectedSegmentIndex = 2
            self.homeController?.openAddress() // FIXME:

        case 3:
            segmentedControl.selectedSegmentIndex = 3
            let storyboard = UIStoryboard(name: "MileIQ", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MileVC") as! PlacesCollectionView
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.present(vc, animated: true)
        default:
            break;
        }
    }

}
