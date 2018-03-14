//
//  AddCategory.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

struct Item {
    var category: String?
    var image: UIImage

    init(image: UIImage) {
        self.image = image
    }
}

class AddCategoryVC: UIViewController {
    @IBOutlet weak var imagesScrollView: UIScrollView!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!

    var items: [UIImage] = []
    var itemCategoriesDict: [UIImage: String] = [:] {
        didSet {
            checkCategoriesCompletion()
        }
    }
    var indexOfCurrentImage: Int {
        return Int(imagesScrollView.contentOffset.x / imagesScrollView.bounds.width)
    }

    let firebaseManager = FirebaseManager.shared
    let userStuffManager = UserStuffManager.shared
    let notificationCenter = NotificationCenter.default

    let numberOfColumns = 2
    let edgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 5, right: 5)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidLayoutSubviews() {
        setScrollViewImages()
    }

    private func setupViews() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(touchedCancel))

        imagesScrollView.delegate = self
        imagesScrollView.isPagingEnabled = true

        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        categoriesCollectionView.allowsSelection = true
        categoriesCollectionView.allowsMultipleSelection = false
    }

    private func setScrollViewImages() {
        let scrollViewWidth = CGFloat(items.count) * imagesScrollView.bounds.width

        imagesScrollView.contentSize = CGSize(width: scrollViewWidth, height: imagesScrollView.bounds.height)

        for (index,image) in items.enumerated() {
            let imageXPoint = CGFloat(index) * imagesScrollView.bounds.width
            let imageViewRect = CGRect(x: imageXPoint, y: 0, width: imagesScrollView.bounds.width, height: imagesScrollView.bounds.height)
            let imageView = UIImageView(frame: imageViewRect)

            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            imagesScrollView.addSubview(imageView)
        }
    }

    @objc private func touchedCancel() {
        let message = "Are you sure you want to cancel?"
        let subtitleMessage = "Your items won't be saved!"
        let rightButtonData = ButtonData(title: "Yes, I'm Sure", color: .fixedFitPurple) { [weak self] in
            self?.userStuffManager.closet.removeTemporaryCategories(insertToUserCategories: false)
            self?.dismiss(animated: true, completion: nil)
        }
        let leftButtonData = ButtonData(title: "Nevermind", color: .fixedFitBlue, action: nil)
        let informationVC = InformationVC(message: message, subtitle: subtitleMessage, image: #imageLiteral(resourceName: "question"), leftButtonData: leftButtonData, rightButtonData: rightButtonData)

        present(informationVC, animated: true, completion: nil)
    }

    @objc private func touchedDone() {
        let message = "Uploading..."
        let informationVC = InformationVC(message: message, image: #imageLiteral(resourceName: "addCategory"), leftButtonData: nil, rightButtonData: nil)

        present(informationVC, animated: true, completion: nil)

        firebaseManager.uploadClosetItems(itemCategoriesDict) { [weak self] (error) in
            if let _ = error {
                print("We got into some weird error!")
            } else {
                self?.userStuffManager.closet.removeTemporaryCategories(insertToUserCategories: false)
                self?.notificationCenter.post(name: .categoriesUpdated, object: nil)
                informationVC.dismiss(animated: true, completion: nil)
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc func presentAddNewcategoryAlert() {
        let alertController = UIAlertController(title: "Add category", message: "Enter the name of the category", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let enterAction = UIAlertAction(title: "Enter", style: .default, handler: { [weak self] _ in
            let newcategory = alertController.textFields?[0].text ?? ""

            if !newcategory.isEmpty {
                self?.userStuffManager.closet.addNewCategory(newcategory)
                self?.categoriesCollectionView.reloadData()
            }
        })

        enterAction.isEnabled = false
        alertController.addTextField(configurationHandler: { [weak self] (textField) in
            textField.addTarget(self, action: #selector(self?.editedNewcategoryTextField), for: .editingChanged)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(enterAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func editedNewcategoryTextField(_ sender: Any) {
        let textField = sender as! UITextField
        var responder: UIResponder! = textField

        while !(responder is UIAlertController) {
            responder = responder.next
        }

        let alert = responder as! UIAlertController

        alert.actions[1].isEnabled = textField.text != ""
        alert.actions[1].isEnabled = !userStuffManager.closet.allCategories.contains(textField.text ?? "")
    }

    private func checkCategoriesCompletion() {
        if itemCategoriesDict.count == items.count {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(touchedDone))
        }
    }
}

extension AddCategoryVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.imagesScrollView else { return }
        categoriesCollectionView.reloadData()
    }
}

extension AddCategoryVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userStuffManager.closet.allCategories.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < userStuffManager.closet.allCategories.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCell.identifier, for: indexPath) as! categoryCell
            let category = Array(userStuffManager.closet.allCategories)[indexPath.row]
            let currentImage = items[indexOfCurrentImage]

            cell.categoryCellLabel.text = category
            cell.gestureRecognizers?.removeAll()

            if itemCategoriesDict.contains(where: { (image,foundcategory) -> Bool in return currentImage == image && category == foundcategory }) {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
                cell.categoryCellLabel.backgroundColor = .fixedFitPurple
                cell.categoryCellLabel.textColor = .white
            } else {
                cell.isSelected = false
                collectionView.deselectItem(at: indexPath, animated: true)
                cell.categoryCellLabel.backgroundColor = .fixedFitGray
                cell.categoryCellLabel.textColor = .black
            }

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddcategoryCell.identifier, for: indexPath) as! AddcategoryCell

            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentAddNewcategoryAlert)))
            cell.backgroundColor = UIColor.fixedFitGray
            cell.layer.borderColor = nil
            cell.layer.borderWidth = 0

            return cell
        }
    }
}

extension AddCategoryVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let _ = collectionView.cellForItem(at: indexPath) as? categoryCell else { return false }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! categoryCell
        let image = items[indexOfCurrentImage]

        cell.categoryCellLabel.backgroundColor = .fixedFitPurple
        cell.categoryCellLabel.textColor = .white
        itemCategoriesDict[image] = cell.categoryCellLabel.text ?? ""
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! categoryCell

        cell.categoryCellLabel.backgroundColor = UIColor.fixedFitGray
        cell.categoryCellLabel.textColor = .black
    }
}

extension AddCategoryVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableSpace = collectionView.bounds.width - (edgeInsets.left * CGFloat(numberOfColumns + 1))
        let cellWidth = availableSpace / CGFloat(numberOfColumns)

        return CGSize(width: cellWidth, height: 70)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return edgeInsets.bottom
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return edgeInsets.bottom
    }
}
