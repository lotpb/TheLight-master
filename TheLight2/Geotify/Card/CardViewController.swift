//
//  CardViewController.swift
//  CardViewAnimation
//
//  Created by Brian Advent on 26.10.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit


class CardViewController: UIViewController {

    var homeController: GeotificationVC?

    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toolbarView: UIView!

    lazy var searchBtn: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        let boldFont = UIFont.boldSystemFont(ofSize: 24)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)
        button.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: configuration), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var addBtn: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        let boldFont = UIFont.boldSystemFont(ofSize: 24)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)
        button.setImage(UIImage(systemName: "slider.horizontal.3", withConfiguration: configuration), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var chevronBtn: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        let boldFont = UIFont.boldSystemFont(ofSize: 20)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)
        button.setImage(UIImage(systemName: "chevron.compact.up", withConfiguration: configuration), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var listBtn: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        let boldFont = UIFont.boldSystemFont(ofSize: 20)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)
        button.setImage(UIImage(systemName: "list.bullet", withConfiguration: configuration), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var offLineBtn: UIButton = {
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

    let offlineLabel: UILabel = {
        let label = UILabel()
        label.text = "GO OFFLINE"
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
        topView.backgroundColor = .secondarySystemBackground
        tableView.backgroundColor = .secondarySystemFill
        centerView.backgroundColor = .secondarySystemFill

        titleLabel.textColor = .label
        setupConstraints()
        floatButton()
    }

    private func floatButton() {

        let btnLayer2: CALayer = offLineBtn.layer
        btnLayer2.cornerRadius = 76 / 2
        btnLayer2.masksToBounds = true
    }

    func setupConstraints() {

        self.view.addSubview(offLineBtn)
        self.view.addSubview(searchBtn)
        self.view.addSubview(addBtn)
        self.view.addSubview(chevronBtn)
        self.view.addSubview(listBtn)
        self.view.addSubview(offlineLabel)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            chevronBtn.topAnchor.constraint(equalTo: handleArea.topAnchor, constant: 10),
            chevronBtn.leadingAnchor.constraint(equalTo: handleArea.leadingAnchor, constant: 20),
            chevronBtn.widthAnchor.constraint(equalToConstant: 40),
            chevronBtn.heightAnchor.constraint(equalToConstant: 40),

            listBtn.topAnchor.constraint(equalTo: handleArea.topAnchor, constant: 15),
            listBtn.trailingAnchor.constraint(equalTo: handleArea.trailingAnchor, constant: -20),
            listBtn.widthAnchor.constraint(equalToConstant: 40),
            listBtn.heightAnchor.constraint(equalToConstant: 40),

            searchBtn.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 30),
            searchBtn.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 30),
            searchBtn.widthAnchor.constraint(equalToConstant: 40),
            searchBtn.heightAnchor.constraint(equalToConstant: 40),

            addBtn.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 30),
            addBtn.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -30),
            addBtn.widthAnchor.constraint(equalToConstant: 40),
            addBtn.heightAnchor.constraint(equalToConstant: 40),

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
            self.homeController?.openRegion() //fix

        case 2:
            segmentedControl.selectedSegmentIndex = 2
            self.homeController?.openAddress() //fix

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
