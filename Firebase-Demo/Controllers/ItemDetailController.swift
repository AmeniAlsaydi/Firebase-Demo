//
//  ItemDetailController.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore // has a listener

class ItemDetailController: UIViewController {

    @IBOutlet weak var containerBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    
    private var item: Item
    private var originalValueForConstraint: CGFloat = 0
    private var dataService = DatabaseService()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(dismissKeyboard))
        return gesture
        
    }()
    
    private var listener: ListenerRegistration?
    
    private var comments = [Comment]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM, d, h:m a"
        return formatter
    }()
    
    init?(coder: NSCoder, item: Item) { // coder is needed since were coming from storyboard, coder converts the story board to 
        self.item = item
        
        super.init(coder:coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection).document(item.id).collection(DatabaseService.commentCollection).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Try again", message: error.localizedDescription)
                }
            } else if let snapshot = snapshot {
                // create comments using dictionary intializer from the comment model
                let comments = snapshot.documents.map {Comment($0.data())}
                self.comments = comments.sorted {$0.commentDate.dateValue() < $1.commentDate.dateValue()} // sorts from most recent to least recent?
                
                
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = item.name
        tableView.tableHeaderView = HeaderView(imageUrl: item.imageURL)
        tableView.dataSource = self

        registerKeyboardNotification()
        originalValueForConstraint = containerBottomConstraints.constant
        commentTextField.delegate = self
        view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unregisterKeyboardNotification()
        listener?.remove()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
        // TOOD:
        
        guard let commentText = commentTextField.text, !commentText.isEmpty else {
            showAlert(title: "Missing feilds", message: "No comment")
            return 
        }
         postComment(text: commentText)
        
    }
    
    private func postComment(text: String) {
        
        dataService.postComment(item: item, comment: text) { (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "Try again", message: error.localizedDescription)
                }
                
            case .success:
                DispatchQueue.main.async {
                    self.showAlert(title: "Comment posted", message: "success")
                }
            }
        }
        
    }
    
    private func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    private func unregisterKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
               
        
    }
    
    @objc private func keyboardWillShow(_ notificaiton: Notification) {
        
        print(notificaiton.userInfo ?? "")
        
        guard let keyboardframe = notificaiton.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect else {
            return
        }
        
        containerBottomConstraints.constant = -(keyboardframe.height - view.safeAreaInsets.bottom)
        
    }
    
    @objc private func keyboardWillHide(_ notificaiton: Notification) {
        dismissKeyboard()
    }
    
    @objc private func dismissKeyboard() {
        containerBottomConstraints.constant = originalValueForConstraint
        commentTextField.resignFirstResponder()
    }
    
}

extension ItemDetailController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}

extension ItemDetailController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let comment = comments[indexPath.row]
        let dateString = dateFormatter.string(from: comment.commentDate.dateValue())
        
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = "@" + comment.commentedBy + " on " + dateString
        return cell
    }
    
    
}
