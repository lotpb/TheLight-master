//
//  ContactController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/20/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
//import Contacts
import ContactsUI

private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


final class ContactVC: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak var noContactsLabel: UILabel!
//    @IBOutlet weak private var searchBar: UISearchBar!
    
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    
    // data
    var contacts = [CNContact]()
    var contactStore = CNContactStore()
    var contactEntry = [ContactEntry]()
    
    private var authStatus: CNAuthorizationStatus = .denied {
        didSet { // switch enabled search bar, depending contacts permission
            //searchBar.isUserInteractionEnabled = authStatus == .authorized
            if authStatus == .authorized { // all search
                contacts = fetchContacts("")
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .secondarySystemGroupedBackground
        } else {
            // Fallback on earlier versions
        }
        setupTableView()
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = true
        noContactsLabel.isHidden = false
        noContactsLabel.text = "Retrieving contacts..."
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        setMainNavItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestAccessToContacts { (success) in
            if success {
                self.retrieveContacts({ (success, contacts) in
                    self.tableView.isHidden = !success
                    self.noContactsLabel.isHidden = success
                    if success, contacts?.count > 0 {
                        self.contactEntry = contacts!
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    } else {
                        self.noContactsLabel.text = "Unable to get contacts..."
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func createNewContact(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "CreateContact", sender: sender)
    }

    func setupNavigation() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(createNewContact))
        navigationItem.rightBarButtonItems = [addButton]
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = "TheLight - Contacts"
        } else {
            navigationItem.title = "Contacts"
        }
        
        searchController = UISearchController(searchResultsController: resultsController)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    func setupTableView() {
        
        self.tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")

        if #available(iOS 13.0, *) {
            self.tableView!.backgroundColor = .systemGray4
        } else {
            self.tableView!.backgroundColor = Color.LGrayColor
        }
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.backgroundColor = Color.LGrayColor
        resultsController.tableView.sizeToFit()
        resultsController.tableView.clipsToBounds = true
        resultsController.tableView.dataSource = self
        //resultsController.tableView.delegate = self
        resultsController.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func requestAccessToContacts(_ completion: @escaping (_ success: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            self.authStatus = .authorized //added
            completion(true) // authorized previously
        case .denied, .notDetermined: // needs to ask for authorization
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (accessGranted, error) in
                completion(accessGranted)
            })
        default: // not authorized.
            completion(false)
        }
    }
    
    func retrieveContacts(_ completion: (_ success: Bool, _ contacts: [ContactEntry]?) -> Void) {
 
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactOrganizationNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
 
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                if let contact = ContactEntry(cnContact: cnContact) { self.contactEntry.append(contact) }
            })
            completion(true, contactEntry)
        } catch {
            completion(false, nil)
        }
    }
    
    func fetchContacts(_ name: String) -> [CNContact] {
        
        do {
            let request = CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)])
            if name.isEmpty { // all search
                request.predicate = nil
            } else {
                request.predicate = CNContact.predicateForContacts(matchingName: name)
            }
            
            try contactStore.enumerateContacts(with: request, usingBlock: { (contact, error) in
                self.contacts.append(contact)
            })
            
            return contacts
        } catch let error as NSError {
            NSLog("Fetch error \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - UISearchBarDelegate
    private func searchContact(_ name: String) {
        
        do {
            //let contacts = CNMutableContact()
            //contacts.givenName = "Peter"
            //contacts.familyName = "Balsamo"
            let predicate = CNContact.predicateForContacts(matchingName: name)
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey]
            let store = CNContactStore()
            
            let contacts = try store.unifiedContacts(
                matching: predicate,
                keysToFetch: keysToFetch as [CNKeyDescriptor]
            )
            
            if let firstContact = contacts.first {
                let viewController = CNContactViewController(for: firstContact)
                viewController.contactStore = store
                present(viewController, animated: true)
            }
            //return contacts
            
        } catch let error as NSError {
            NSLog("Fetch error \(error.localizedDescription)")
            return 
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        guard let dvc = segue.destination as? CreateContactVC else { return }
            dvc.type = .cnContact */
        
        if
            segue.identifier == "EditFriendSegue",
            // 1
            let cell = sender as? ContactTableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let _ = segue.destination as? CreateContactVC {
            let friend = contactEntry[indexPath.row]
            // 2
            let store = CNContactStore()
            // 3
            let predicate = CNContact.predicateForContacts(matchingEmailAddress: friend.name)
            // 4
            let keys = [CNContactPhoneNumbersKey as CNKeyDescriptor]
            // 5
            if
                let contacts = try? store.unifiedContacts(matching: predicate, keysToFetch: keys),
                let contact = contacts.first,
                let _ = contact.phoneNumbers.first {
                // 6
                /*
 
                 friend.storedContact = contact.mutableCopy() as? CNMutableContact
                 friend.phoneNumberField = contactPhone
                 friend.identifier = contact.identifier*/
            }
            //CreateContactVC. = friend
        }
    }
}
//-----------------------end------------------------------
extension ContactVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        contacts = fetchContacts(searchText)
        tableView.reloadData()
    }
}

extension ContactVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactEntry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        if #available(iOS 13.0, *) {
            cell.backgroundColor = .secondarySystemGroupedBackground
        } else {
            // Fallback on earlier versions
        }
        
        //cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        let entry = contactEntry[indexPath.row]
        cell.configureWithContactEntry(entry)
        cell.layoutIfNeeded()
        
        return cell
    }
}

extension ContactVC {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //1
        let friend = contactEntry[indexPath.row]
        let contact = friend.contactValue

        //2
        let contactViewController = CNContactViewController(for: contact)
        contactViewController.navigationItem.title = "Profile"
        contactViewController.hidesBottomBarWhenPushed = true
        //3
        contactViewController.allowsEditing = false
        contactViewController.allowsActions = false
        //4
        navigationController?.pushViewController(contactViewController, animated: true)
    }
}

extension ContactVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
    
        /*
        filteredTitles.removeAll(keepingCapacity: false)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope) */
    }
}
