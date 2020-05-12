//
//  MapViewCard.swift
//  TheLight2
//
//  Created by Peter Balsamo on 3/24/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import UIKit

class CardMapController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        addBtn.addTarget(self, action: #selector(addButton), for: .touchUpInside)
        self.textView.backgroundColor = .white
        self.textView.textColor = .black

        //self.cardMapController.textView.textColor = .label

        
        self.textView.isSelectable = false
        self.startLabel.textColor = .white

    }


    @objc func addButton() { //dont work fix
        addBtn.addTarget(self, action: #selector(addButton), for: .touchUpInside)

    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
