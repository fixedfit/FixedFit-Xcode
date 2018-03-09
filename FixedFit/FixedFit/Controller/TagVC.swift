//
//  TagVC.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/2/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit

struct Item {
    var tag: String?
    var image: UIImage

    init(image: UIImage) {
        self.image = image
    }
}

class TagVC: UIViewController {
    @IBOutlet weak var imagesScrollView: UIScrollView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!

    var items: [UIImage] = []
    var itemTagsDict: [UIImage: String] = [:] {
        didSet {
            checkTagsCompletion()
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

        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        tagsCollectionView.allowsSelection = true
        tagsCollectionView.allowsMultipleSelection = false
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
            self?.userStuffManager.removeTemporaryTags(insertToUserTags: false)
            self?.dismiss(animated: true, completion: nil)
        }
        let leftButtonData = ButtonData(title: "Nevermind", color: .fixedFitBlue, action: nil)
        let informationVC = InformationVC(message: message, subtitle: subtitleMessage, image: #imageLiteral(resourceName: "question"), leftButtonData: leftButtonData, rightButtonData: rightButtonData)

        present(informationVC, animated: true, completion: nil)
    }

    @objc private func touchedDone() {
        firebaseManager.uploadClosetItems(itemTagsDict)
        userStuffManager.removeTemporaryTags(insertToUserTags: true)
        notificationCenter.post(name: .tagsUpdated, object: nil)
        dismiss(animated: true, completion: nil)
    }

    @objc func presentAddNewTagAlert() {
        let alertController = UIAlertController(title: "Add tag", message: "Enter the name of the tag", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let enterAction = UIAlertAction(title: "Enter", style: .default, handler: { [weak self] _ in
            let newTag = alertController.textFields?[0].text ?? ""

            if !newTag.isEmpty {
                self?.userStuffManager.addNewTag(newTag)
                self?.tagsCollectionView.reloadData()
            }
        })

        enterAction.isEnabled = false
        alertController.addTextField(configurationHandler: { [weak self] (textField) in
            textField.addTarget(self, action: #selector(self?.editedNewTagTextField), for: .editingChanged)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(enterAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func editedNewTagTextField(_ sender: Any) {
        let textField = sender as! UITextField
        var responder: UIResponder! = textField

        while !(responder is UIAlertController) {
            responder = responder.next
        }

        let alert = responder as! UIAlertController

        alert.actions[1].isEnabled = textField.text != ""
        alert.actions[1].isEnabled = !userStuffManager.tags.contains(textField.text ?? "")
    }

    private func checkTagsCompletion() {
        if itemTagsDict.count == items.count {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(touchedDone))
        }
    }
}

extension TagVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.imagesScrollView else { return }
        tagsCollectionView.reloadData()
    }
}

extension TagVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userStuffManager.tags.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < userStuffManager.tags.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as! TagCell
            let tag = Array(userStuffManager.tags)[indexPath.row]
            let currentImage = items[indexOfCurrentImage]

            cell.tagCellLabel.text = tag
            cell.gestureRecognizers?.removeAll()

            if itemTagsDict.contains(where: { (image,foundTag) -> Bool in return currentImage == image && tag == foundTag }) {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
                cell.tagCellLabel.backgroundColor = .fixedFitPurple
                cell.tagCellLabel.textColor = .white
            } else {
                cell.isSelected = false
                collectionView.deselectItem(at: indexPath, animated: true)
                cell.tagCellLabel.backgroundColor = .fixedFitGray
                cell.tagCellLabel.textColor = .black
            }

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddTagCell.identifier, for: indexPath) as! AddTagCell

            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentAddNewTagAlert)))
            cell.backgroundColor = UIColor.fixedFitGray
            cell.layer.borderColor = nil
            cell.layer.borderWidth = 0

            return cell
        }
    }
}

extension TagVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let _ = collectionView.cellForItem(at: indexPath) as? TagCell else { return false }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TagCell
        let image = items[indexOfCurrentImage]

        cell.tagCellLabel.backgroundColor = .fixedFitPurple
        cell.tagCellLabel.textColor = .white
        itemTagsDict[image] = cell.tagCellLabel.text ?? ""
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TagCell

        cell.tagCellLabel.backgroundColor = UIColor.fixedFitGray
        cell.tagCellLabel.textColor = .black
    }
}

extension TagVC: UICollectionViewDelegateFlowLayout {
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
