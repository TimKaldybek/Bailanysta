//
//  UIViewController+CustomNavigationBar.swift
//  Bailanysta
//
//

import UIKit

extension UIViewController {
    func setupNavigationBar(leftImage: UIImage? = nil, rightImage: UIImage? = nil) {
        if let leftImage {
            let imageView = createImageView(image: leftImage)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: imageView)
        }

        if let rightImage {
            let imageView = createImageView(image: rightImage)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
        }
    }
    
    func setupNavigationBarTitle(_ titleText: String) {
        let label = UILabel()
        label.text = titleText
        label.textColor = Color.label
        label.font = .systemFont(ofSize: 24, weight: .medium)
        
        navigationItem.titleView = label
    }
    
    private func createImageView(image: UIImage) -> UIImageView {
        let imageview = UIImageView()
        imageview.image = image
        imageview.contentMode = .scaleAspectFit
        imageview.tintColor = Color.label
        
        return imageview
    }
}

