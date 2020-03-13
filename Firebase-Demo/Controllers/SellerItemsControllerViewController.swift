//
//  SellerItemsControllerViewController.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SellerItemsControllerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var item: Item
    
    private var items = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    init?(coder: NSCoder, item: Item) {
        self.item = item
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchItems()
        fetchUserPhoto()
        navigationItem.title = "@" + item.sellerName
    }
    private func fetchItems() {
        //TODO: refactor DatabaseService to a singleton
        //ex: DatabaseService.shared --> private init() static let shared = DatabaseService()
        DatabaseService().fetchUserItems(userId: item.sellerId) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Could not get user's items", message: error.localizedDescription)
                }
            case .success(let items):
                self?.items = items
            }
        }
        
    }
    private func fetchUserPhoto() {
        Firestore.firestore().collection(DatabaseService.usersCollection).document(item.sellerId).getDocument { [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "error getting user", message: error.localizedDescription)
                }
            } else if let snapshot = snapshot {
                //could be refactored to a user model
                if let photoURL = snapshot.data()?["photoURL"] as? String {
                    DispatchQueue.main.async {
                        self?.tableView.tableHeaderView = HeaderVIew(imageURL: photoURL)
                    }
                }
            }
        }
    }
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
    }
    
}
extension SellerItemsControllerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("could not down cast to item cell")
        }
        let item = items[indexPath.row]
        cell.configureCell(item: item)
        return cell
    }
}
extension SellerItemsControllerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
