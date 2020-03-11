//
//  HeaderView.swift
//  Firebase-Demo
//
//  Created by Amy Alsaydi on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher

// https://developer.apple.com/documentation/uikit/uitableview/1614904-tableheaderview

class HeaderView: UIView {
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "mic")
        return iv
    }()

    init(imageUrl: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        
        commonInit()
        imageView.kf.setImage(with: URL(string: imageUrl))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupImageConstraints()
    }
    
    private func setupImageConstraints() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor)
            
        ])
    }

}
