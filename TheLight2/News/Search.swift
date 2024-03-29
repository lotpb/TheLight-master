//
//  Search.swift
//  YouTube
//
//  Created by Haik Aslanyan on 7/4/16.
//  Copyright © 2016 Haik Aslanyan. All rights reserved.
//

protocol SearchDelegate {
    func hideSearchView(status : Bool)
}

import UIKit


@available(iOS 13.0, *)
final class Search: UIView, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //MARK: Properties
    let statusView: UIView = {
        let st = UIView(frame: CGRect.zero)
        st.backgroundColor = UIColor.black
        st.alpha = 0.15
        return st
    }()
    
    lazy var searchView: UIView = {
       let sv = UIView.init(frame: .init(x: 0, y: 10, width: self.frame.width, height: 60))
        sv.backgroundColor = UIColor.white
        sv.alpha = 0
        return sv
    }()
    
    lazy var backgroundView: UIView = {
        let bv = UIView.init(frame: self.frame)
        bv.backgroundColor = UIColor.black
        bv.alpha = 0
        return bv
    }()
    
    lazy var backButton: UIButton = {
       let bb = UIButton.init(frame: .init(x: 0, y: 20, width: 30, height: 30))
        bb.setBackgroundImage(UIImage(systemName: "magnifyingglass"), for: [])
        bb.addTarget(self, action: #selector(Search.dismiss), for: .touchUpInside)
        return bb
    }()
    
    lazy var searchField: UITextField = {
        let sf = UITextField.init(frame: .init(x: 48, y: 20, width: self.frame.width - 50, height: 48))
        sf.placeholder = "Seach on Youtube..."
        sf.keyboardAppearance = .dark
        return sf
    }()
    
    lazy var tableView: UITableView = {
        let tv: UITableView = UITableView.init(frame: .init(x: 0, y: 68, width: self.frame.width, height: 288))
        return tv
    }()
    
    var items = [String]()
    
    var delegate:SearchDelegate?
    
    //MARK: Methods
    func customization()  {
        self.addSubview(self.backgroundView)
        self.backgroundView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(Search.dismiss)))
        self.addSubview(self.searchView)
        searchView.addSubview(self.searchField)
        searchView.addSubview(self.backButton)
        tableView.register(searchCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.clear
        searchField.delegate = self
        self.addSubview(self.statusView)
    }
    
    func animate()  {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.alpha = 0.5
            self.searchView.alpha = 1
            self.searchField.becomeFirstResponder()
        })
    }
    
    @objc func  dismiss()  {
        self.searchField.text = ""
        self.items.removeAll()
        tableView.removeFromSuperview()
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.alpha = 0
            self.searchView.alpha = 0
            self.searchField.resignFirstResponder()
            }, completion: {(Bool) in
                self.delegate?.hideSearchView(status: true)
        })
    }
    
    //MARK: TextField Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (self.searchField.text == "" || self.searchField.text == nil) {
            self.items = []
            tableView.removeFromSuperview()
        } else {
            let _  = URLSession.shared.dataTask(with: requestSuggestionsURL(text: self.searchField.text!), completionHandler: { (data, response, error) in
                if error == nil {
                    do {
                        let json  = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                        self.items = json[1] as! [String]
                        DispatchQueue.main.async(execute: {
                            if self.items.count > 0  {
                                self.addSubview(self.tableView)
                            } else {
                                self.tableView.removeFromSuperview()
                            }
                            self.tableView.reloadData()
                        })
                    } catch _ {
                        print("Something wrong happened")
                    }
                } else {
                    print("error downloading suggestions")
                }
            }).resume()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismiss()
        return true
    }
    
    //MARK: TableView Delegates and Datasources
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! searchCell
            cell.itemLabel.text = items[indexPath.row]
        //cell.backgroundColor = UIColor.rbg(r: 245, g: 245, b: 245)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchField.text = items[indexPath.row]
    }
    
    //MARK: Inits
   override init(frame: CGRect) {
        super.init(frame: frame)
        customization()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        tableView.separatorStyle = .none
    }
}

class searchCell: UITableViewCell {
    
    lazy var itemLabel: UILabel = {
        let il: UILabel = UILabel.init(frame: .init(x: 48, y: 0, width: self.contentView.bounds.width - 48, height: self.contentView.bounds.height))
        il.textColor = .systemGray
        return il
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "Cell")
        self.addSubview(itemLabel)
    }
    
   required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
