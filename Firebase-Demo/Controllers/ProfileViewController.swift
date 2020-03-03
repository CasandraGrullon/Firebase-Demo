//
//  ProfileViewController.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        displayNameTextField.delegate = self
        updateUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateUI()
    }
    
    private func updateUI() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        //user.displayName
        //user.photoURL
        //user.phoneNumber
        emailLabel.text = user.email
        displayNameTextField.text = user.displayName
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIBarButtonItem) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        UIViewController.showViewController(storyboardName: "LoginView", viewcontrollerID: "LoginViewController")
    }
    
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        //change the user's display name
        
        guard let displayName = displayNameTextField.text, !displayName.isEmpty else {
            showAlert(title: "Missing Fields!", message: "Please fill out all required fields")
            return
        }
        
        //1. make a request
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        
        //2. change display name
        request?.displayName = displayName
        
        //3. commit changes made
        request?.commitChanges(completion: { [unowned self] (error) in
            if let error = error {
                self.showAlert(title: "Error", message: "commit changes error \(error)")
            } else {
                self.showAlert(title: "Success", message: "successfully updated display name")
            }
        })
    }
    
}
extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
