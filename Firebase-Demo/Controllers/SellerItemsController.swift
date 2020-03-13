//
//  SellerItemsController.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SellerItemsController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
   
    private var item: Item
    
    private var items = [Item]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // failable initialializer
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
        
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")

        tableView.tableHeaderView = HeaderView(imageUrl: item.imageURL)
    }
    
    private func fetchItems() {
        // TODO: refactor DatabaseService and StorageService to a singleton since we creating new instances throughout our application
        // DatabaseService {
        // private init() {}
        // static let shared = DatabaseService()
        // DatabaseService.shared.function
        
        
        DatabaseService().fetchUsersItems(userId: item.sellerId) { (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "Failed fetching", message: error.localizedDescription)
                }
            case .success(let items):
                self.items = items
            }
        }
    }
    
    private func fetchUserPhoto() {
        Firestore.firestore().collection(DatabaseService.userCollection).document(item.sellerId).getDocument { [weak self] (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "error fetching user", message: error.localizedDescription)
                }
                
            } else if let snapshot = snapshot {
                // TO DO: could be refracted to a user model
                if let photoUrl = snapshot.data()?["photoUrl"] as? String {
                    DispatchQueue.main.async {
                        self?.tableView.tableHeaderView = HeaderView(imageUrl: photoUrl)
                    }
                }
                
            }
        }
    }
}

extension SellerItemsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell else {
            fatalError("could not downcast to item cell")
        }
        item = items[indexPath.row]
        cell.configureCell(for: item)
        return cell
    }

}

extension SellerItemsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
