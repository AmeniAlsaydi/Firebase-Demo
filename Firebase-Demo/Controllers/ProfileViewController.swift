//
//  ProfileViewController.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

enum ViewState {
    case myItems
    case favorites
}

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameTextFeild: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
     private var refreshControl: UIRefreshControl!
    
    private lazy var imagePickerController: UIImagePickerController = {
      let ip = UIImagePickerController()
      ip.delegate = self
      return ip
    }()
    
    private var selectedImage: UIImage? {
      didSet {
        profileImageView.image = selectedImage
      }
    }
    
    // use this instance to upload photo
    private let storageService = StorageService()
    private let databaseService = DatabaseService()
    
    private var viewState: ViewState = .myItems {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData() // logic in table view data source
            }
        }
    }
    
    private var favorites = [Favorite]() {
        didSet {
            tableView.reloadData() // logic in table view data source
        }
    }
    
    private var myItems = [Item]() {
        didSet {
            tableView.reloadData() // logic in table view data source
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserInfo()
        displayNameTextFeild.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        loadData()
        
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: (#selector(loadData)), for: .valueChanged)
    }
    
    @objc private func loadData() {
        fetchItems()
        fetchFavorites()
    }
    
    
    private func configureRefreshControl() {
        
    }
    
    @objc private func fetchItems() {
        // we need the current user id
        
        guard let user = Auth.auth().currentUser else {
            refreshControl.endRefreshing()
            return
            
        }
        
        databaseService.fetchUsersItems(userId: user.uid) { [weak self ] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error fetching items", message: error.localizedDescription)
                    
                }
            case .success(let items):
                self?.myItems = items
            }
            
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func fetchFavorites() {
        databaseService.fetchFavorites { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error fetching favs", message: error.localizedDescription)
                    
                }
            case .success(let favorites):
                self?.favorites = favorites
            }
            
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
        
    }
    
    
    private func getUserInfo() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        emailLabel.text = user.email
        displayNameTextFeild.text = user.displayName
        profileImageView.kf.setImage(with: user.photoURL)
        // user.email
        // user.phoneNumber
        // user.photoURL
    
    }
    
    
    @IBAction func updateProfileButtonPressed(_ sender: UIButton) {
        
        // to change the users display name we need a request
        
        guard let displayName = displayNameTextFeild.text, !displayName.isEmpty, let selectedImage = selectedImage else {
            print("missing fields")
            return
        }
        
        guard let user = Auth.auth().currentUser else { return }
        
        // resize image
        let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: profileImageView.bounds)
        
        //print("original image size: \(selectedImage.size)")
        //print("resized image size: \(resizedImage.size)")
        
        // call storageServices.upload
        storageService.uploadPhoto(userId: user.uid, image: resizedImage) { [weak self] (result) in
            // code here to add the photoURL to the user's photoURL property then commit changes
            
            switch result {
            case .failure(let error):
                self?.showAlert(title: "error uploading photo/ updating profile", message: "\(error.localizedDescription)")
            case .success(let url):
                self?.updateDatabaseUser(displayName: displayName, photoUrl: url.absoluteString)
                let request = Auth.auth().currentUser?.createProfileChangeRequest()
                request?.displayName = displayName
                request?.photoURL = url
                
                request?.commitChanges(completion: { [unowned self] (error) in
                    if let error = error  {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Error updating profile", message: "Error: changing an alert \(error.localizedDescription) ")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.showAlert(title:"Profile change" , message: "profile successfully created")
                        }
                    }
                })
            }
        }

    }
    
    private func updateDatabaseUser(displayName: String, photoUrl: String) {
        databaseService.updateDatabaseUser(displayName: displayName, photoUrl: photoUrl) { (result) in
            switch result {
            case .failure(let error):
                print("failed to update user profile: \(error.localizedDescription)")
                //self.showAlert(title: "error updating profile", message: error.localizedDescription)
            case .success:
                print("successfully updated user ")
            }
        }
        
    }
    
   @IBAction func editProfilePhotoButtonPressed(_ sender: UIButton) {
      let alertController = UIAlertController(title: "Choose Photo Option", message: nil, preferredStyle: .actionSheet)
      let cameraAction = UIAlertAction(title: "Camera", style: .default) { alertAction in
        self.imagePickerController.sourceType = .camera
        self.present(self.imagePickerController, animated: true)
      }
      let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { alertAction in
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true)
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        alertController.addAction(cameraAction)
      }
      alertController.addAction(photoLibraryAction)
      alertController.addAction(cancelAction)
      present(alertController, animated: true)
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        
        // sign out could throw an error
        
        do {
            try Auth.auth().signOut()
            UIViewController.showViewController(storyBoardName: "LoginView", viewControllerId: "LoginViewController")
        } catch {
            self.showAlert(title: "Error signing out", message: "\(error.localizedDescription)")
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
        resignFirstResponder()
        return true
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
        } else if viewState == .favorites {
            return favorites.count
        }
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell else {
            fatalError("could not down cast to item cell")
        }
        
        if viewState == .myItems {
            let item = myItems[indexPath.row]
            cell.configureCell(for: item)
        } else if viewState == .favorites {
           let favorite = favorites[indexPath.row]
            cell.configureCell(for: favorite)
            // cell.configureCell(item: favorite)
        }
       
        return cell
    }
    
    
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144
    }
}
