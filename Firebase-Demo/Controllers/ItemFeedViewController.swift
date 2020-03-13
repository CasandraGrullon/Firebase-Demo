//
//  ItemFeedViewController.swift
//  Firebase-Demo
//
//  Created by casandra grullon on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ItemFeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var listener: ListenerRegistration?
    private var databaseService = DatabaseService()
    
    private var items = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //tableview will update when items are added by the snapshot listener
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Firestore Error", message: "\(error)")
                }
            } else if let snapshot = snapshot {
                //snapshot == data in Firebase
                let items = snapshot.documents.map { Item($0.data()) }
                self?.items = items 
            }
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //will no longer need to listen for changes from Firebase when the view dismisses
        listener?.remove()
    }
    
    
}
extension ItemFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            fatalError("could not cast to item cell")
        }
        let item = items[indexPath.row]
        cell.configureCell(item: item)
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let detailSb = UIStoryboard(name: "MainView", bundle: nil)
        let detailVC = detailSb.instantiateViewController(identifier: "ItemDetailViewController") { (coder) in
            return ItemDetailViewController(coder: coder, item)
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //delete item
            let item = items[indexPath.row]
            databaseService.deleteItem(item: item) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Could not delete item \(item)", message: error.localizedDescription)
                    }
                case .success:
                    print("deleted item successfully")
                }
            }
        }
    }
    // On client side: make sure the current user can only delete items they created on the app and on firebase console
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let user = Auth.auth().currentUser else {
            return false
        }
        let item = items[indexPath.row]
        
        if item.sellerId == user.uid {
            return true
        } else {
            return false
        }
    }
    // to protect against accidental deletion, we will need to protect database on Firebase Security Rules
    
}
extension ItemFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

extension ItemFeedViewController: ItemCellDelegate {
    func didTapSellerName(_ itemCell: ItemCell, item: Item) {
        let storyboard = UIStoryboard(name: "MainView", bundle: nil)
        let sellerItemsVC = storyboard.instantiateViewController(identifier: "SellerItemsControllerViewController") { (coder) in
            return SellerItemsControllerViewController(coder: coder, item: item)
        }
        navigationController?.pushViewController(sellerItemsVC, animated: true)        
    }
    
    
}
