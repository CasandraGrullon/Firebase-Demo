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
    
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    private var selectedImage = UIImage() {
        didSet{
            DispatchQueue.main.async {
                self.profilePicture.image = self.selectedImage
            }
        }
    }
    
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
    
    @IBAction func editProfilePicButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Edit Profile Picture", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { alertAction in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { alertAction in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) //don't need a handeler because the action style .cancel has that built in!
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        
        alertController.addAction(photoLibrary)
        alertController.addAction(cancel)
        present(alertController, animated: true)
        
    }
    
    
    @IBAction func signOutButtonPressed(_ sender: UIBarButtonItem) {
        
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
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //guarding against optional image user selected
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        selectedImage = image
        
        
        dismiss(animated: true)
    }
    
}
