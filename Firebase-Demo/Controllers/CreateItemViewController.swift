//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateItemViewController: UIViewController {
    
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    
    private var category: Category
    
    private let dbService = DatabaseService()
    private let storageService = StorageService()
    
    private var selectedImage: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.itemImageView.image = self.selectedImage
            }
        }
    }
    
    private lazy var imagePickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        return picker
    }()
    
    private lazy var longpressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(showPhotoOptions(_:)))
        return gesture
    }()
    
    init?(coder: NSCoder, category: Category) {
        self.category = category
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = category.name
        
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(longpressGesture)
        
        itemPriceTextField.delegate = self
        itemNameTextField.delegate = self
    }
    
    @objc private func showPhotoOptions(_ sender: UILongPressGestureRecognizer) {
        let alertController = UIAlertController(title: "Choose Photo", message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { (alertAction) in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (alertAction) in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(camera)
        }
        alertController.addAction(photoLibrary)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let itemName = itemNameTextField.text, !itemName.isEmpty,
            let priceText = itemPriceTextField.text, !priceText.isEmpty,
            let price = Double(priceText),
            let itemImage = selectedImage else {
                showAlert(title: "Missing Fields", message: "All fields and an item image are required")
                return
        }
        
        guard let displayName = Auth.auth().currentUser?.displayName else {
            showAlert(title: "Profile Incomplete", message: "Please add a username to continue")
            return
        }
        
        let resizePhoto = UIImage.resizeImage(originalImage: itemImage, rect: itemImageView.bounds)
        
        let dateListed = Date().convertDate()
        
        dbService.createItem(itemName: itemName, price: price, category: category, displayName: displayName, dateListed: dateListed) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Could not create item \(error)")
                }
            case .success(let docID):
                //Upload Photo to storage
                self?.uploadPhoto(photo: resizePhoto, documentId: docID)
            }
        }
        
    }
    private func uploadPhoto(photo: UIImage, documentId: String) {
        //converting image to data
        storageService.uploadPhoto(itemId: documentId ,image: photo) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "error uploading photo \(error)")
                }
            case .success(let url):
                self?.updateItemImageURL(url, documentId: documentId)
            }
        }
    }
    private func updateItemImageURL(_ url: URL, documentId: String) {
        //update an exisiting document on Firebase
        Firestore.firestore().collection(DatabaseService.itemsCollection).document(documentId).updateData(["imageURL": url.absoluteString]) { [weak self] (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "failed to update item", message: " \(error)")
                }
            } else {
                //print("all went well")
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
}
extension CreateItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension CreateItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("could not get original image")
        }
        selectedImage = image
        
        dismiss(animated: true)
        
    }
}

