//
//  SnapHeadviewCell.swift
//  TheLight2
//
//  Created by Peter Balsamo on 10/6/19.
//  Copyright © 2019 Peter Balsamo. All rights reserved.
//

import UIKit


final class SnapHeaderviewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    lazy var vw: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var headView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 10.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel(frame: .init(x: 20, y: 15, width: 200, height: 40))
        label.text = "Snapshot"
        label.textColor = .label
        label.font = Font.celltitle30b
        return label
    }()

    let titleLabel1: UILabel = {
        let label = UILabel(frame: .init(x: 20, y: 65, width: 150, height: 20))
        label.text = "Backend Data"
        label.textColor = .label
        label.font = Font.celltitle16l
        return label
    }()

    let titleLabel2: UILabel = {
        let label = UILabel(frame: .init(x: 20, y: 90, width: 150, height: 20))
        label.text = "Weather"
        label.textColor = .label
        label.font = Font.celltitle16l
        return label
    }()

    let titleLabeltxt1: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .systemRed
        label.font = Font.celltitle16r
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let titleLabeltxt2: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .systemRed
        label.font = Font.celltitle16r
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let myListLbl: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = Font.celltitle14r
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    func setupViews() {

        self.contentView.addSubview(vw)
        addSubview(myListLbl)

        addSubview(headView)
        headView.addSubview(titleLabel)
        headView.addSubview(titleLabel1)
        headView.addSubview(titleLabel2)
        headView.addSubview(titleLabeltxt1)
        headView.addSubview(titleLabeltxt2)

        NSLayoutConstraint.activate([
            vw.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            vw.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            vw.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            vw.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),

            headView.topAnchor.constraint(equalTo: vw.topAnchor, constant: 20),
            headView.leadingAnchor.constraint(equalTo: vw.leadingAnchor, constant: 15),
            headView.trailingAnchor.constraint(equalTo: vw.trailingAnchor, constant: -15),
            headView.heightAnchor.constraint(equalToConstant: 130),

            titleLabeltxt1.topAnchor.constraint(equalTo: titleLabel1.topAnchor, constant: 2),
            titleLabeltxt1.trailingAnchor.constraint(equalTo: headView.trailingAnchor, constant: -20),
            titleLabeltxt1.heightAnchor.constraint(equalToConstant: 20),

            titleLabeltxt2.topAnchor.constraint(equalTo: titleLabel2.topAnchor, constant: 2),
            titleLabeltxt2.trailingAnchor.constraint(equalTo: headView.trailingAnchor, constant: -20),
            titleLabeltxt2.heightAnchor.constraint(equalToConstant: 20),

            myListLbl.leadingAnchor.constraint(equalTo: vw.leadingAnchor, constant: 20),
            myListLbl.trailingAnchor.constraint(equalTo: vw.trailingAnchor, constant: -15),
            myListLbl.bottomAnchor.constraint(equalTo: vw.bottomAnchor, constant: 0),
        ])
    }
}
