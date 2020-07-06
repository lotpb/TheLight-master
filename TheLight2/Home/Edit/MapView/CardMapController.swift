//
//  MapViewCard.swift
//  TheLight2
//
//  Created by Peter Balsamo on 3/24/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import UIKit

class CardMapController: UIViewController {

    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var titleLabel: UILabel!

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

    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let startLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = Font.celltitle18r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let destLabel: UILabel = {
        let label = UILabel()
        label.text = "Dest"
        label.font = Font.celltitle18r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let distanceView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let timeView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let directionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .secondarySystemFill
        textView.textColor = .label
        textView.isSelectable = false
        return textView
    }()

    public let timeBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.triangle.turn.up.right.circle.fill")?
                            .withRenderingMode(.alwaysOriginal), for:.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    public let distanceBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "car.circle.fill")?
                            .withRenderingMode(.alwaysOriginal), for:.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    public let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Time:"
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Distance:"
        label.font = Font.celltitle16r
        label.backgroundColor = .clear
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let toolbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemFill
        optionBtn.addTarget(self, action: #selector(addButton), for: .touchUpInside)
        self.titleLabel.textColor = .label
    }

    @objc func addButton() { // TODO: dont work fix
        optionBtn.addTarget(self, action: #selector(addButton), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.addSubview(chevronBtn)
        view.addSubview(listBtn)
        view.addSubview(mainView)
        mainView.addSubview(topView)
        mainView.addSubview(startLabel)
        mainView.addSubview(destLabel)
        mainView.addSubview(timeView)
        mainView.addSubview(timeBtn)
        mainView.addSubview(timeLabel)
        mainView.addSubview(distanceView)
        mainView.addSubview(distanceBtn)
        mainView.addSubview(distanceLabel)
        mainView.addSubview(directionTextView)
        mainView.addSubview(toolbarView)
        mainView.addSubview(searchBtn)
        mainView.addSubview(optionBtn)

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
            topView.heightAnchor.constraint(equalToConstant: 85),

            startLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 10),
            startLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 15),
            startLabel.heightAnchor.constraint(equalToConstant: 30),

            destLabel.topAnchor.constraint(equalTo: startLabel.bottomAnchor, constant: 5),
            destLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 15),
            destLabel.heightAnchor.constraint(equalToConstant: 30),

            timeView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 10),
            timeView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            timeView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10),
            timeView.heightAnchor.constraint(equalToConstant: 60),

            distanceView.topAnchor.constraint(equalTo: timeView.bottomAnchor, constant: 10),
            distanceView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            distanceView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10),
            distanceView.heightAnchor.constraint(equalToConstant: 60),

            timeBtn.leadingAnchor.constraint(equalTo: timeView.leadingAnchor, constant: 10),
            timeBtn.heightAnchor.constraint(equalToConstant: 30),
            timeBtn.centerYAnchor.constraint(equalTo: timeView.centerYAnchor),

            distanceBtn.leadingAnchor.constraint(equalTo: distanceView.leadingAnchor, constant: 10),
            distanceBtn.heightAnchor.constraint(equalToConstant: 30),
            distanceBtn.centerYAnchor.constraint(equalTo: distanceView.centerYAnchor),

            timeLabel.leftAnchor.constraint(equalTo: timeBtn.rightAnchor, constant: 10),
            timeLabel.centerYAnchor.constraint(equalTo: timeView.centerYAnchor),

            distanceLabel.leftAnchor.constraint(equalTo: distanceBtn.rightAnchor, constant: 10),
            distanceLabel.centerYAnchor.constraint(equalTo: distanceView.centerYAnchor),

            directionTextView.topAnchor.constraint(equalTo: distanceView.bottomAnchor, constant: 10),
            directionTextView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            directionTextView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10),
            directionTextView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor, constant: -10),

            toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toolbarView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 100),

            searchBtn.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 20),
            searchBtn.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 30),
            searchBtn.widthAnchor.constraint(equalToConstant: 40),
            searchBtn.heightAnchor.constraint(equalToConstant: 40),

            optionBtn.topAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 20),
            optionBtn.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -30),
            optionBtn.widthAnchor.constraint(equalToConstant: 40),
            optionBtn.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
