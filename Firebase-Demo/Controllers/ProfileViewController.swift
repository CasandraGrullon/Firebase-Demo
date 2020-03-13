//
//  ProfileViewController.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

enum ViewState {
    case favorites
    case myItems
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    private var viewState: ViewState = .myItems {
        didSet {
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    private var favorites = [Favorite]() {
        didSet {
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    private var myItems = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    private var selectedImage: UIImage? {
        didSet{
            DispatchQueue.main.async {
                self.profilePicture.image = self.selectedImage
            }
        }
    }
    
    private let storageService = StorageService()
    private let databaseService = DatabaseService()
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameTextField.delegate = self
        updateUI()
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        loadData()
        refreshControl = UIRefreshControl()
        tableview.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateUI()
    }
    @objc private func loadData() {
        fetchItems()
        fetchFavorites()
    }
    @objc private func fetchItems() {
        guard let user = Auth.auth().currentUser else {
            refreshControl.endRefreshing()
            return
        }
        databaseService.fetchUserItems(userId: user.uid) { [weak self] (result) in
            switch result {
            case .failure(let error):
                print("could not load items \(error)")
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            case .success(let items):
                self?.myItems = items
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            }
        }
    }
    @objc private func fetchFavorites() {
        databaseService.fetchFavorites(completion: { [weak self] (result) in
            switch result {
            case .failure(let error):
                print("could not load favorites \(error)")
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            case .success(let favorites):
                self?.favorites = favorites
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            }
        })
    }
    
    private func updateUI() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        profilePicture.kf.setImage(with: user.photoURL)
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
        do {
            try Auth.auth().signOut()
            UIViewController.showViewController(storyboardName: "LoginView", viewcontrollerID: "LoginViewController")
        } catch {
            DispatchQueue.main.async {
                self.showAlert(title: "Could not log out", message: "\(error.localizedDescription)")
            }
        }
        
    }
    
    @IBAction func updateButtonPressed(_ sender: UIBarButtonItem) {
        //change the user's display name and profile picture
        guard let displayName = displayNameTextField.text, !displayName.isEmpty,
            let selectedImage = selectedImage else {
                showAlert(title: "Missing Fields!", message: "Please fill out all required fields")
                return
        }
        
        let resizeImage = UIImage.resizeImage(originalImage: selectedImage, rect: profilePicture.bounds)
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        storageService.uploadPhoto(userId: user.uid ,image: resizeImage) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Upload Error", message: "could not upload image\(error)")
                }
            case .success(let url):
                self?.updateDatabaseUser(displayName: displayName, photoURL: url.absoluteString)
                let request = Auth.auth().currentUser?.createProfileChangeRequest()
                
                //2. change display name and update photo
                request?.displayName = displayName
                request?.photoURL = url
                
                //3. commit changes made
                request?.commitChanges(completion: { [unowned self] (error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Error", message: "commit changes error \(error)")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Success", message: "successfully updated your profile")
                            
                        }
                    }
                })
            }
        }
    }
    
    private func updateDatabaseUser(displayName: String, photoURL: String) {
        databaseService.updateDatabaseUser(displayName: displayName, photoURL: photoURL) { (result) in
            switch result {
            case .failure(let error):
                print("failed to update user \(error)")
            case .success:
                print("successfully updated db user")
            }
        }
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            viewState = .myItems
        case 1:
            viewState = .favorites
        default:
            break
        }
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
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewState == .myItems {
            return myItems.count
        } else {
            return favorites.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("could not cast to item cell")
        }
        if viewState == .myItems {
            let item = myItems[indexPath.row]
            cell.configureCell(item: item)
        } else {
            let favorite = favorites[indexPath.row]
            cell.configureCell(favorite: favorite)
        }
        
        return cell
    }
    
    
}
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
