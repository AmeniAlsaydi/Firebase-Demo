//
//  SellItemViewController.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class SellItemViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var categories = Category.getCategories()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

    }
}

extension SellItemViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            fatalError("could not downcast to cell")
        }
        let category = categories[indexPath.row]
        cell.configureCell(for: category)
        return cell
    }
    
}

extension SellItemViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxSize: CGSize = UIScreen.main.bounds.size
        let spacingBetweenItems: CGFloat = 11
        let numberOfItems: CGFloat = 3
        let totalSpacing:CGFloat = (2 * spacingBetweenItems) + (numberOfItems - 1) * (spacingBetweenItems)
        let itemWidth: CGFloat = (maxSize.width - totalSpacing) / numberOfItems
        let itemHeight: CGFloat = (maxSize.height) * 0.2
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         //TODO:
         //segue to createItemViewController
         let category = categories[indexPath.row]
         let mainViewStoryboard = UIStoryboard(name: "MainView", bundle: nil)
         let createItemVC = mainViewStoryboard.instantiateViewController(identifier: "CreateItemViewController") { (coder) in
           return CreateItemViewController(coder: coder, category: category)
         }
         //present in a navigation controller
         present(UINavigationController(rootViewController: createItemVC), animated: true)
       }
    
}
