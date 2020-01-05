//
//  PhotoGalleryVC.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/6/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData
import ImagePicker
import Kingfisher
import PKHUD
import UIKit

class PhotoGalleryVC: UICollectionViewController, UIGestureRecognizerDelegate {
    let cellIdentifier = "ImageCell"

    var managedObjectContext: NSManagedObjectContext!
    var estateService: EstateService!

    var estate: Estate!
    var allImages: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(CustomCell.self, forCellWithReuseIdentifier: cellIdentifier)

//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
//            action:@selector(activateDeletionMode:)];
//        longPress.delegate = self;
//        [collectionView addGestureRecognizer:longPress];

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(activateDeletionMode(_:)))
        longPress.delegate = self
        collectionView?.addGestureRecognizer(longPress)

        // Right bar to add photos
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openImagePicker(_:)))
        navigationItem.rightBarButtonItem = rightBarButton
    }

    func setupWith(estate: Estate, managedObjectContext: NSManagedObjectContext) {
        self.estate = estate
        self.managedObjectContext = managedObjectContext
        estateService = EstateService(managedObjectContext: managedObjectContext)
        reloadImages()
    }

    func reloadImages() {
        allImages = estate.allImages()
    }

    func buildImagePickerController() -> ImagePickerController {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = Limits.imageLimit
        return imagePickerController
    }

    @objc func openImagePicker(_: Any) {
        let imagePicker = buildImagePickerController()
        navigationController?.pushViewController(imagePicker, animated: true)
        hideTabBar()
    }

    func hideTabBar() {
        let appTabBarController = tabBarController as? AppTabBarController
        appTabBarController?.hide()
        navigationController?.navigationBar.isHidden = true
    }

    func unhideTabBar() {
        let appTabBarController = tabBarController as? AppTabBarController
        appTabBarController?.unhide()
        navigationController?.navigationBar.isHidden = false
    }

    @objc func activateDeletionMode(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if let indexPath = collectionView?.indexPathForItem(at: point) {
                let confirm = UIAlertController(title: nil, message: "Are you sure you want to delete this photo?", preferredStyle: .actionSheet)
                confirm.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self.removeImage(at: indexPath, from: self.collectionView!)
                }))
                confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(confirm, animated: true, completion: nil)
            }
        }
    }

    func removeImage(at indexPath: IndexPath, from _: UICollectionView) {
        // TODO: Fixme
//        try estateService.deleteImageFrom(estate: estate, at: indexPath.row)
//        reloadImages()
//        collectionView?.deleteItems(at: [indexPath])
        let alert = Alert.simple(title: "Not yet implemented", message: "This feature is not implemented just yet! 😅")
        present(alert, animated: true, completion: nil)
    }
}

// Media handling
extension PhotoGalleryVC: ImagePickerDelegate {
    func wrapperDidPress(_: ImagePickerController, images: [UIImage]) {
        print("Wrapped did press: \(images.count)")
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("Done: \(images.count)")
        if images.isEmpty {
            let alert = Alert.simple(title: "Validation failed", message: "Please select at least one image")
            imagePicker.present(alert, animated: true, completion: nil)
            return
        }

//        log.info("Sync success!")
//        HUD.show(.label("Saving..."))
        HUD.show(.label("Uploading images..."))

        // Save estate
        let estateSyncher = EstateSyncAction(context: managedObjectContext)
        do {
            // Upload, save and associate images to this estate locally
            try estateService.append(images: images, to: estate)
            // Use: self.estateImages
            estateSyncher.uploadAndSaveImages(estate: estate).then { results in
                print(results)
                HUD.flash(.success, delay: 0.5)

                self.navigationController?.popViewController(animated: true)
                self.unhideTabBar()

                self.reloadImages()
                self.collectionView?.reloadData()
            }.catch { error in
                print(error)
                HUD.hide()
                let alert = Alert.simple(title: "Save failed", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
            }

        } catch {
            let alert = Alert.simple(title: "Validation failed", message: "Error trying to save the image: \(error)")
            imagePicker.present(alert, animated: true, completion: nil)
        }

//        // Save iamges
//        do {
//            try estateService.append(images: images, to: estate)
//            try estateService.saveContext()
//            reloadImages()
//            collectionView?.reloadData()
//        } catch {
//            let alert = Alert.simple(title: "Validation failed", message: "Error trying to save the image: \(error)")
//            imagePicker.present(alert, animated: true, completion: nil)
//        }
    }

    func cancelButtonDidPress(_: ImagePickerController) {
        print("Cancel")
        navigationController?.popViewController(animated: true)
        unhideTabBar()
    }
}

extension PhotoGalleryVC: UICollectionViewDelegateFlowLayout {
    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return allImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CustomCell
        let image = allImages[indexPath.row]
//        if let url = URL(string: allImages) {
//            cell.imgView.kf.setImage(with: url)
//        } else {
//            // TODO: Show error image
//        }
        cell.imgView.image = image
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: (width - 15) / 2, height: (width - 15) / 2)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 5
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 5
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout,
                        insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}

class CustomCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.red
        addSubview(imgView)
        imgView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imgView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imgView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let imgView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "car.jpg")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
}
