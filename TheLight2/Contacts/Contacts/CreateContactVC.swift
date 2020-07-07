//
//  CreateContactViewController.swift
//  AddressBookContacts
//
//  Created by Ignacio Nieto Carvajal on 21/4/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import Contacts
//import AddressBook

enum ContactType {
    case addressBookContact
    case cnContact
}

final class CreateContactVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // outlets
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var emailAddressTextfield: UITextField!
    @IBOutlet weak var phoneNumberTextfield: UITextField!
    
    // data
    var type: ContactType?
    var contactImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contactImageView.layer.cornerRadius = contactImageView.frame.size.width / 2.0
        contactImageView.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // create contact

    @available(iOS 9.0, *)
    func createCNContactWithFirstName(_ firstName: String, lastName: String, email: String?, phone: String?, image: UIImage?) {
        // create contact with mandatory values: first and last name
        let newContact = CNMutableContact()
        newContact.givenName = firstName
        newContact.familyName = lastName
        
        // email
        if email != nil {
            let contactEmail = CNLabeledValue(label: CNLabelHome, value: email! as NSString)
            newContact.emailAddresses = [contactEmail]
        }
        // phone
        if phone != nil {
            let contactPhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: phone!))
            newContact.phoneNumbers = [contactPhone]
        }
        // image
        if image != nil {
            newContact.imageData = image?.jpegData(compressionQuality: 0.9)
        }
        
        do {
            let newContactRequest = CNSaveRequest()
            newContactRequest.add(newContact, toContainerWithIdentifier: nil)
            try CNContactStore().execute(newContactRequest)
            self.presentingViewController?.dismiss(animated: true)
        } catch {
            self.showAlert(title: "Oops!", message: "I was unable to create the new contact. An error occurred.")
        }
    }
    
    // MARK: - Button actions
    @IBAction func createContact(_ sender: AnyObject) {
        // check if we can create a contact.
        if let firstName = firstNameTextfield.text , firstName.count > 0,
            let lastName = lastNameTextfield.text , lastName.count > 0 {
            let email = emailAddressTextfield.text
            let phone = phoneNumberTextfield.text
            
            createCNContactWithFirstName(firstName, lastName: lastName, email: email, phone: phone, image: contactImage)

        } else {
            self.showAlert(title: "Oops!", message: "Please, insert at least a first and last name for the contact.")
        }
    }
    
    @IBAction func changeContactImage(_ sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        self.contactImageView.image = image
    }
    
    
    @IBAction func goBack(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
}
