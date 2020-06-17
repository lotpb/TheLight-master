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
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!

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


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemGroupedBackground
        addBtn.addTarget(self, action: #selector(addButton), for: .touchUpInside)
        self.titleLabel.textColor = .label
        self.textView.backgroundColor = .secondarySystemGroupedBackground
        self.textView.textColor = .label
        self.textView.isSelectable = false
        self.startLabel.textColor = .label
        setupConstraints()
    }


    @objc func addButton() { //dont work fix
        addBtn.addTarget(self, action: #selector(addButton), for: .touchUpInside)
    }

    func setupConstraints() {

        self.view.addSubview(chevronBtn)
        self.view.addSubview(listBtn)

        NSLayoutConstraint.activate([
            chevronBtn.topAnchor.constraint(equalTo: handleArea.topAnchor, constant: 10),
            chevronBtn.leadingAnchor.constraint(equalTo: handleArea.leadingAnchor, constant: 20),
            chevronBtn.widthAnchor.constraint(equalToConstant: 40),
            chevronBtn.heightAnchor.constraint(equalToConstant: 40),

            listBtn.topAnchor.constraint(equalTo: handleArea.topAnchor, constant: 15),
            listBtn.trailingAnchor.constraint(equalTo: handleArea.trailingAnchor, constant: -20),
            listBtn.widthAnchor.constraint(equalToConstant: 40),
            listBtn.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
