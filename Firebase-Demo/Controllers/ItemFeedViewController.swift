//
//  ItemFeedViewController.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ItemFeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let databaseService = DatabaseService()
    
    private var listener: ListenerRegistration? // observes for changes from firebase
    
    private var items = [Item]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        // register a nib file
        
//        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Try again later", message: "\(error.localizedDescription)")
                }
            } else if let snapshot = snapshot {
                let items = snapshot.documents.map { Item($0.data())}
                self?.items = items
            }
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listener?.remove()
    }
}

extension ItemFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell else {
            fatalError("could not down cast to ItemCell")
        }
        
        let item = items[indexPath.row]
        cell.delegate = self
        cell.configureCell(for: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //this gives us the ability to swipe to delete
        
        let item = items[indexPath.row]
        if editingStyle == .delete {
            // perform deletion - only have to remove it from the database we already have a listener
            databaseService.delete(item: item) { (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showAlert(title: "Deletion error", message: error.localizedDescription)
                    }
                case .success:
                    print("deleted \(item.name) successfully")
                }
            }
        }
    }
    
    // on the client size meaning the aoo will ensure that swipe to delete only works for the user who created the item
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // is editing allowed by the user
        
        let item = items[indexPath.row]
        
        guard let user = Auth.auth().currentUser else { return false }
        
        if item.sellerId != user.uid {
            return false
        }
        return true
    }
    // TODO: its not enough to only prevent accidental deletion on the client,  we need to protect the database as we will, we will do so using firebase "Security rules"
    
}

extension ItemFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        // access story board that has that scene
        
        let storyboard = UIStoryboard(name: "MainView", bundle: nil)
        let detailVC = storyboard.instantiateViewController(identifier: "ItemDetailController") {
            (coder) in
            return ItemDetailController(coder: coder, item: item)
            
        }
        navigationController?.pushViewController(detailVC, animated: true)

    }
}

extension ItemFeedViewController: ItemCellDelegate {
    func didSelectSellerName(_ itemCell: ItemCell, item: Item) {
        
        let storyboard = UIStoryboard(name: "MainView", bundle: nil)
        // takes in a coder and an id
        let sellerItemsVC = storyboard.instantiateViewController(identifier: "SellerItemsController") { (coder) in
            return SellerItemsController(coder: coder, item: item)
        }
        
        navigationController?.pushViewController(sellerItemsVC, animated: true)
        print("in vc \(item.sellerName) was seleted")
    }
}
