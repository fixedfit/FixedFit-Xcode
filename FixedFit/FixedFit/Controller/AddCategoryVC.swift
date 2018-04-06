//
//  AddCategory.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

class AddCategoryVC: UIViewController {
    @IBOutlet weak var imagesScrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!

    var photos: [UIImage] = []
    var closet: Closet!
    var photoCategorySubcategoryDict: [UIImage: CategorySubcategory] = [:] {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = allPhotosCategorized()
        }
    }
    var selectedCategory: String?
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
        print("Ayeyooooo!")
        setupViews()
        closet = userStuffManager.closet
    }

    override func viewDidLayoutSubviews() {
        setScrollViewImages()
    }

    private func setupViews() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(touchedCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(touchedDone))
        navigationItem.rightBarButtonItem?.isEnabled = false

        imagesScrollView.delegate = self
        imagesScrollView.isPagingEnabled = true

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
    }

    private func setScrollViewImages() {
        let scrollViewWidth = CGFloat(photos.count) * imagesScrollView.bounds.width

        imagesScrollView.contentSize = CGSize(width: scrollViewWidth, height: imagesScrollView.bounds.height)

        for (index,image) in photos.enumerated() {
            let imageXPoint = CGFloat(index) * imagesScrollView.bounds.width
            let imageViewRect = CGRect(x: imageXPoint, y: 0, width: imagesScrollView.bounds.width, height: imagesScrollView.bounds.height)
            let imageView = UIImageView(frame: imageViewRect)

            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            imagesScrollView.addSubview(imageView)
        }
    }

    @objc func presentAddNewCategoryAlert(_ tapGestureRecognizer: UITapGestureRecognizer) {
        guard let addCategoryCell = tapGestureRecognizer.view as? AddCategoryCell else { return }
        let isSubcategory = addCategoryCell.tag == 1 ? true : false

        let alertController = UIAlertController(title: "Add category", message: "Enter the name of the category", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let enterAction = UIAlertAction(title: "Enter", style: .default, handler: { [weak self] _ in
            let newCategory = alertController.textFields?[0].text ?? ""

            if !newCategory.isEmpty {
                if isSubcategory {
                    if let selectedCategory = self?.selectedCategory {
                        self?.closet.categorySubcategoryStore.addSubcategory(category: selectedCategory, subcategory: newCategory)
                    }
                } else {
                    self?.closet.categorySubcategoryStore.addCategory(category: newCategory)
                }

                self?.collectionView.reloadData()
            }
        })

        enterAction.isEnabled = false
        alertController.addTextField(configurationHandler: { [weak self] (textField) in
            textField.tag = addCategoryCell.tag
            textField.addTarget(self, action: #selector(self?.editedNewCategoryTextField), for: .editingChanged)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(enterAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func touchedCancel() {
        let message = "Are you sure you want to cancel?"
        let subtitleMessage = "Your items won't be saved!"
        let rightButtonData = ButtonData(title: "Yes, I'm Sure", color: .fixedFitPurple) { [weak self] in
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

        firebaseManager.uploadClosetItems(photoCategorySubcategoryDict) { [weak self] (error) in
            if let _ = error {
                print("We got into some weird error!")
            } else {
                self?.notificationCenter.post(name: .categoriesUpdated, object: nil)
                informationVC.dismiss(animated: true) { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    @objc private func editedNewCategoryTextField(_ sender: Any) {
        let textField = sender as! UITextField
        var responder: UIResponder! = textField

        while !(responder is UIAlertController) {
            responder = responder.next
        }

        let alert = responder as! UIAlertController
        let text = textField.text ?? ""

        if textField.tag == 0 {
            // First section
            alert.actions[1].isEnabled = !closet.categorySubcategoryStore.contains(category: text) && !text.isEmpty
        } else {
            // Second section
            if let selectedCategory = selectedCategory {
                alert.actions[1].isEnabled = !closet.categorySubcategoryStore.subcategories(for: selectedCategory).contains(text) && !text.isEmpty
            }
        }
    }

    // MARK: - Helper methods

    private func allPhotosCategorized() -> Bool {
        guard photoCategorySubcategoryDict.count == photos.count else { return false }

        var allPhotosCategorized = true

        for photoCategoryDict in photoCategorySubcategoryDict {
            if photoCategoryDict.value.category == nil {
                allPhotosCategorized = false
            }
        }

        return allPhotosCategorized
    }

    func photoCategorySubcategoryDictContains(image: UIImage, category: String) -> Bool {
        func matches(_ tuple: (foundImage: UIImage, foundCategorySubcategory: CategorySubcategory)) -> Bool {
            if  tuple.foundImage == image && tuple.foundCategorySubcategory.category ?? "" == category {
                return true
            } else {
                return false
            }
        }

        if photoCategorySubcategoryDict.contains(where: { return matches($0) }) {
            return true
        } else {
            return false
        }
    }

    func photoCategorySubcategoryDictContains(image: UIImage, subcategory: String) -> Bool {
        func matches(_ tuple: (foundImage: UIImage, foundCategorySubcategory: CategorySubcategory)) -> Bool {
            return tuple.foundImage == image && tuple.foundCategorySubcategory.subcategory ?? "" == subcategory ? true : false
        }

        if photoCategorySubcategoryDict.contains(where: { return matches($0) }) {
            return true
        } else {
            return false
        }
    }

    func addCategoryCell(collectionView: UICollectionView, indexPath: IndexPath) -> AddCategoryCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddCategoryCell.identifier, for: indexPath) as! AddCategoryCell

        cell.tag = indexPath.section
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentAddNewCategoryAlert)))
        cell.backgroundColor = UIColor.fixedFitGray
        cell.layer.borderColor = nil
        cell.layer.borderWidth = 0

        return cell
    }
}

extension AddCategoryVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.imagesScrollView else { return }
        collectionView.reloadData()
    }
}

extension AddCategoryVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionTitleCell.identifier, for: indexPath) as! SectionTitleCell

        if indexPath.section == 0 {
            sectionTitleCell.titleLabel.text = "Pick a category"
        } else {
            sectionTitleCell.titleLabel.text = "Pick a subcategory"
        }

        return sectionTitleCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 20)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return closet.categorySubcategoryStore.allCategories.count + 1
        } else {
            if let categoryName = self.selectedCategory {
                let subCategories = closet.categorySubcategoryStore.subcategories(for: categoryName)
                return subCategories.count + 1
            } else {
                return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentImage = photos[indexOfCurrentImage]

        if indexPath.section == 0 {
            // First section
            if indexPath.row < closet.categorySubcategoryStore.allCategories.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
                let category = closet.categorySubcategoryStore.allCategories[indexPath.row]

                cell.categoryCellLabel.text = category
                cell.gestureRecognizers?.removeAll()

                if photoCategorySubcategoryDictContains(image: currentImage, category: category) {
                    cell.isSelected = true
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
                    cell.categoryCellLabel.backgroundColor = .fixedFitPurple
                    cell.categoryCellLabel.textColor = .white
                    selectedCategory = category
                } else {
                    cell.isSelected = false
                    collectionView.deselectItem(at: indexPath, animated: true)
                    cell.categoryCellLabel.backgroundColor = .fixedFitGray
                    cell.categoryCellLabel.textColor = .black
                }

                return cell
            } else {
                return self.addCategoryCell(collectionView: collectionView, indexPath: indexPath)
            }
        } else {
            // Second section
            if indexPath.row < closet.categorySubcategoryStore.subcategories(for: selectedCategory ?? "").count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
                let subcategories = closet.categorySubcategoryStore.subcategories(for: selectedCategory ?? "")
                let currentImage = photos[indexOfCurrentImage]
                let subcategory = subcategories[indexPath.row]

                cell.categoryCellLabel.text = subcategories[indexPath.row]
                cell.gestureRecognizers?.removeAll()

                if photoCategorySubcategoryDictContains(image: currentImage, subcategory: subcategory) {
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
                return addCategoryCell(collectionView: collectionView, indexPath: indexPath)
            }
        }
    }
}

extension AddCategoryVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let _ = collectionView.cellForItem(at: indexPath) as? CategoryCell else { return false }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        let currentImage = photos[indexOfCurrentImage]

        cell.categoryCellLabel.backgroundColor = .fixedFitPurple
        cell.categoryCellLabel.textColor = .white

        if indexPath.section == 0 {
            // First section
            let categoryName = cell.categoryCellLabel.text ?? ""

            closet.categorySubcategoryStore.addCategory(category: categoryName)

            if var categorySubcategory = photoCategorySubcategoryDict[currentImage] {
                categorySubcategory.category = categoryName
                photoCategorySubcategoryDict[currentImage] = categorySubcategory
            } else {
                photoCategorySubcategoryDict[currentImage] = CategorySubcategory(category: categoryName, subcategory: nil)
            }

            selectedCategory = categoryName
        } else {
            // Second section
            let selectedIndexPath = collectionView.indexPathsForSelectedItems!.first!
            let categoryName = (collectionView.cellForItem(at: selectedIndexPath) as! CategoryCell).categoryCellLabel.text!
            let subcategoryName = cell.categoryCellLabel.text ?? ""

            closet.categorySubcategoryStore.addSubcategory(category: categoryName, subcategory: subcategoryName)

            if var categorySubcategory = photoCategorySubcategoryDict[currentImage] {
                categorySubcategory.subcategory = subcategoryName
                photoCategorySubcategoryDict[currentImage] = categorySubcategory
            } else {
                photoCategorySubcategoryDict[currentImage] = CategorySubcategory(category: nil, subcategory: subcategoryName)
            }
        }

        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        
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
