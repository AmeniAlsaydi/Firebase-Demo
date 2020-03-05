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

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameTextFeild: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         getUserInfo()
        displayNameTextFeild.delegate = self
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
        
        print("original image size: \(selectedImage.size)")
        print("resized image size: \(resizedImage.size)")
        
        // TODO:
        
        // call storageServices.upload
        storageService.uploadPhoto(userId: user.uid, image: resizedImage) { [weak self] (result) in
            // code here to add the photoURL to the user's photoURL property then commit changes
            
            switch result {
            case .failure(let error):
                self?.showAlert(title: "error uploading photo", message: "\(error.localizedDescription)")
            case .success(let url):
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
