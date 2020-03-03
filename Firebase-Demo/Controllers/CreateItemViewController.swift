//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateItemViewController: UIViewController {

    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    
    private var category: Category
    
    private let dbService = DatabaseService()
    
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
        itemPriceTextField.delegate = self
        itemNameTextField.delegate = self
    }

    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let itemName = itemNameTextField.text, !itemName.isEmpty,
            let priceText = itemPriceTextField.text, !priceText.isEmpty,
            let price = Double(priceText) else {
                showAlert(title: "Missing Fields", message: "All fields are required")
                return
        }
        
        guard let displayName = Auth.auth().currentUser?.displayName else {
            showAlert(title: "Profile Incomplete", message: "Please add a username to continue")
            return
        }
        
        
        dbService.createItem(itemName: itemName, price: price, category: category, displayName: displayName) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "Could not create item \(error)")
                }
            case .success:
                DispatchQueue.main.async {
                    self?.showAlert(title: "✅", message: "successfully created item")
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
