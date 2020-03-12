//
//  ItemDetailViewController.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/9/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseAuth
import FirebaseFirestore

class ItemDetailViewController: UIViewController {
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var addCommentButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var grayViewBottomConstraint: NSLayoutConstraint!
    
    private var originalConstraint: CGFloat = 0
    
    private var listener: ListenerRegistration?
    private var db = DatabaseService()
    
    private var isFavorite = false {
        didSet {
            if isFavorite {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
            } else {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")

            }
        }
    }
    private var item: Item
    
    private var comments = [Comment]() {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private lazy var tapGesture: UITapGestureRecognizer = {
       let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(dismissKeyboard))
        return gesture
    }()
    
    init?(coder: NSCoder, _ item: Item) { //because we are using storyboards, we need to use CODER
        self.item = item
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        navigationItem.title = item.itemName
        
        tableView.delegate = self
        tableView.dataSource = self
        commentTextField.delegate = self

        registerKeyboardNotifications()
        view.addGestureRecognizer(tapGesture)
        
        tableView.tableHeaderView = HeaderVIew(imageURL: item.imageURL)
        originalConstraint = grayViewBottomConstraint.constant
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        registerKeyboardNotifications()
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection).document(item.itemId).collection(DatabaseService.commentsColletion).addSnapshotListener({ (snapshot, error) in
            
            if let error = error {
                print("could not access comments collection: \(error)")
            } else if let snapshot = snapshot {
                //create comments using dictionary initializer from the Comment model
                let comments = snapshot.documents.map { Comment($0.data())}
                self.comments = comments
            }
        })
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterKeyboardNotifications()
        listener?.remove()
    }
    
    private func updateUI() {
        db.isItemInFavorites(item: item) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try again", message: error.localizedDescription)
                }
            case .success(let success):
                if success {
                    self?.isFavorite = true
                } else {
                    self?.isFavorite = false
                }
                
            }
        }
    }
    
    private func postComment(commentText: String) {
        db.postComment(item: item, comment: commentText) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try Again", message: error.localizedDescription)
                }
            case .success:
                DispatchQueue.main.async {
                    self?.showAlert(title: "Your comment has been posted!", message: "")
                }
            }
        }
    }
    
    @IBAction func addCommentButtonPressed(_ sender: UIButton) {
        //adds comments collection to item collection to firebase, presents in table view
        guard let comment = commentTextField.text, !comment.isEmpty else {
            showAlert(title: "Missing Fields", message: "You haven't written a comment yet")
            return
        }
        postComment(commentText: comment)
                
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
        if isFavorite {
            db.removeFromFavorites(item: item) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "try again", message: error.localizedDescription)
                    }
                case .success:
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Item removed from favorites", message: "")
                        self?.isFavorite = false
                    }
                }
            }
        } else {
            db.addToFavorites(item: item) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Could not add to favorites", message: error.localizedDescription)
                    }
                case .success:
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Added to Favorites", message: "♥️")
                        self?.isFavorite = true
                    }
                }
            }
        }
    }
    
    
}
extension ItemDetailViewController {
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    @objc private func keyboardWillShow(_ notification: Notification) {
        print(notification.userInfo ?? "")
        guard let keyboardFrame = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect else {
            return
        }
        grayViewBottomConstraint.constant = +(keyboardFrame.height - view.safeAreaInsets.bottom)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        dismissKeyboard()
    }
    @objc func dismissKeyboard() {
        grayViewBottomConstraint.constant = originalConstraint
        commentTextField.resignFirstResponder()
    }
}
extension ItemDetailViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    dismissKeyboard()
    return true
  }
}
extension ItemDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell else {
            fatalError("could not cast to comment cell")
        }
        let comment = comments[indexPath.row]
        cell.configureCell(comment: comment)
        return cell
    }
    
    
}
extension ItemDetailViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}


