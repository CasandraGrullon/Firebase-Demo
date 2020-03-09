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
    
    private var item: Item
    private var comments = [Comment]() {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    init(_ item: Item) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateItemInfo()
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
                    self.comments = comments
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
    }
    
    
    @IBAction func addCommentButtonPressed(_ sender: UIButton) {
        //adds comment to firebase, presents in table view
    }
    
}
