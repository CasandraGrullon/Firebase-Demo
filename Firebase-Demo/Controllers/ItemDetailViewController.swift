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
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var addCommentButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var listener: ListenerRegistration?
    private var db = DatabaseService()
    
    private var item: Item
    
    private var comments = [Comment]() {
        didSet{
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
        }
    }
    
    init?(_ item: Item, coder: NSCoder) {
        self.item = item
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateItemInfo()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        listener = Firestore.firestore().collection(DatabaseService.commentsColletion).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Unable to get comments", message: "\(error)")
                }
            } else if let snapshot = snapshot {
                DispatchQueue.main.async {
                    let comments = snapshot.documents.map {Comment ($0.data())}
                    self.comments = comments.filter {$0.itemId == self.item.itemId}
                }
            }
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listener?.remove()
    }
    
    private func updateItemInfo() {
        itemImage.kf.setImage(with: URL(string: item.imageURL))
        itemNameLabel.text = item.itemName
        sellerNameLabel.text = item.sellerName
        dateLabel.text = item.listedDate.convertDate()
        let price = String(format: "%.2f", item.price)
        priceLabel.text = "$\(price)"
        print(item.itemId)
    }
    
    
    @IBAction func addCommentButtonPressed(_ sender: UIButton) {
        //adds comment to firebase, presents in table view
        guard let comment = commentTextField.text, let user = Auth.auth().currentUser, let username = user.displayName else {
            return
        }
        db.createComment(username: username, userId: user.uid, itemId: item.itemId, comment: comment) { (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "could not create comment", message: "\(error)")
                }
            case .success(let docID):
                Firestore.firestore().collection(DatabaseService.commentsColletion).document(docID).updateData(["comment": comment])
            }
        }
        
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
extension ItemDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

