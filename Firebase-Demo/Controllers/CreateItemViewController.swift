//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth // takesc are of authentication
import FirebaseFirestore // database

class CreateItemViewController: UIViewController {
    
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemPriceTextField: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    
    
    
    private var category: Category
    private var dbService = DatabaseService()
    private let storageService = StorageService()
    
    private lazy var imagePickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self // conform to UIImagePickerControllerDelegate and UINavigationControllerDelegate
        return picker
    }()
    private var selectedImage: UIImage? {
        didSet {
            itemImageView.image = selectedImage
        }
    }
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(showPhotoOptions))
        return gesture
    }()
    
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
        // add long press gesture to itemImageView
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func showPhotoOptions() {
        
        let alertController = UIAlertController(title: "Choose photo option", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alertAction) in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true)
        }
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (alertAction) in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
   
    
    
    @IBAction func PostButtonPressed(_ sender: Any) {
        //dismiss(animated: true)
        
        guard let itemName = itemNameTextField.text,
            !itemName.isEmpty,
            let priceText = itemPriceTextField.text,
            !priceText.isEmpty,
            // guard against
            let selectedImage = selectedImage,
            let price = Double(priceText) else {
                showAlert(title: "Missing Fields", message: "Check all item fields")
                return
        }
        
        guard let displayName = Auth.auth().currentUser?.displayName else {
            showAlert(title: "Incomplete Profile", message: "Please compelete your profile")
            return
        }
        
        // resize image
        
        let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: itemImageView.bounds)
        
        
        dbService.createItem(name: itemName, price: price, category: category, displayName: displayName) { (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "Error creating item", message: error.localizedDescription)
                    
                }
            case .success(let doumentId):
                self.uploadPhoto(image: resizedImage, documentId: doumentId)
                //upload photo to storage
                
            }
        }
        
        
    }
    private func uploadPhoto(image: UIImage, documentId: String) {
        // takes in an image and a item id
        
        storageService.uploadPhoto(itemId: documentId, image: image) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error uploading item photo", message: "\(error.localizedDescription)")
                }
            case .success(let url):
                self?.updateItemImageURL(url, documentId: documentId)
                // update

            }
        }
        
        
    }
    
    private func updateItemImageURL( _ url: URL, documentId: String) {
        // update am exisiitng document on firebase
        Firestore.firestore().collection(DatabaseService.itemsCollection).document(documentId).updateData(["imageURL": url.absoluteString]) { [weak self] (error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "failed to update item", message: "\(error.localizedDescription)")
                }
            } else {
                // everything wemt ok
                print("all went well witht he update")
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
            
        }
        
    }
}

extension CreateItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("couldnt get selectedImage")
        }
        selectedImage = image
        dismiss(animated: true, completion: nil)
    }
    
}
