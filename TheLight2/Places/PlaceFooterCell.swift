//
//  PlaceFooterCell.swift
//  TheLight2
//
//  Created by Peter Balsamo on 3/26/19.
//  Copyright © 2019 Peter Balsamo. All rights reserved.
//

import UIKit


class PlaceFooterCell: UICollectionReusableView {
    
    let numbersLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0.297358036, green: 0.8514089584, blue: 0.389008224, alpha: 1)
        
        numbersLabel.text = "86766786667876123"
        numbersLabel.font = UIFont.systemFont(ofSize: 32)
        numbersLabel.textAlignment = .center
        numbersLabel.adjustsFontSizeToFitWidth = true
        numbersLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(numbersLabel)
        NSLayoutConstraint.activate([
            numbersLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            numbersLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            numbersLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            numbersLabel.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}
