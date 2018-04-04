//
//  ItemCell.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/13/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var checkmarkView: UIView!

    var isPicked: Bool {
        return !checkmarkView.isHidden
    }

    static let identifier = "photoCell"

    override func awakeFromNib() {
        imageView.contentMode = .scaleAspectFill
        setupCheckmarkView()
    }

    func toggleCheckmark() {
        checkmarkView.isHidden = !checkmarkView.isHidden
    }

    private func setupCheckmarkView() {
        let checkmarkView = UIView()
        let checkmarkImageView = UIImageView()

        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(checkmarkView)
        checkmarkView.addSubview(checkmarkImageView)

        checkmarkView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        checkmarkView.fillSuperView()
        checkmarkImageView.image = #imageLiteral(resourceName: "graycheckmark")
        NSLayoutConstraint.activate([
            checkmarkImageView.centerXAnchor.constraint(equalTo: checkmarkView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: checkmarkView.centerYAnchor),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 30),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 40)
            ])

        self.checkmarkView = checkmarkView
        self.checkmarkView.isHidden = true
    }
}
