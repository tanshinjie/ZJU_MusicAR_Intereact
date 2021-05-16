//
//  UIImageViewPannable.swift
//  mySecondApp
//
//  Created by nextlab02 on 2019/7/19.
//  Copyright © 2019 Tan Shin Jie. All rights reserved.
//

import UIKit
import Photos

class UIImageViewPannable: ViewControllerPannable {
    
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
//        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
//        view.addGestureRecognizer(tapGestureRecognizer!)
        self.openPhotoLibrary()
    }
    
    
    @objc func tapGestureAction(_ tapGesture: UITapGestureRecognizer) {
        showAlert()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.openPhotoLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}


    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        self.performSegue(withIdentifier: "goToARView", sender: nil)
//    }
//
//    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            self.imageView.image = image
//        }
//        dismiss(animated: true, completion: nil)
//    }
//
//    //get image from source type
//    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
//
//        //Check is source type available
//        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
//            print("Button capture")
//
//            imagePicker.delegate = self
//            imagePicker.sourceType = .savedPhotosAlbum
//            imagePicker.allowsEditing = false
//
//            present(imagePicker, animated: true, completion: nil)
//
//        }
//    }


extension UIImageViewPannable: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        
        print(info)
        
        // get the image
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: true)
        }
        print("did cancel")
    }
    
    func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("can't open photo library")
            return
        }
        
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        
        present(imagePicker, animated: true)
    }
    
    func openCamera() {
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("camera not supported by this device")
            return
        }
        
        present(imagePicker, animated: true)
    }
    

}


class ViewControllerPannable: UIViewController {
    var panGestureRecognizer: UIPanGestureRecognizer?
    var tapGestureRecognizer: UITapGestureRecognizer?
    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
//        view.addGestureRecognizer(panGestureRecognizer!)
//        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
//        view.addGestureRecognizer(tapGestureRecognizer!)
//    }

    
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)

        if panGesture.state == .began {
            originalPosition = view.center
            currentPositionTouched = panGesture.location(in: view)
        } else if panGesture.state == .changed {
            view.frame.origin = CGPoint(
                x: translation.x,
                y: translation.y
            )
        } else if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: view)

            if velocity.y >= 1500 {
                UIView.animate(withDuration: 0.2
                    , animations: {
                        self.view.frame.origin = CGPoint(
                            x: self.view.frame.origin.x,
                            y: self.view.frame.size.height
                        )
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.center = self.originalPosition!
                })
            }
        }
    }
}
