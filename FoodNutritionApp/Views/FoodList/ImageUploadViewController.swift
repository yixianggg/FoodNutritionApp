//
//  ImageUploadViewController.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 3/7/25.
//

import Foundation
import UIKit

class ImageUploadViewController: UIViewController {
    
    weak var delegate: ImageUploadViewControllerDelegate?
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Please select or take a photo of your food or beverage text!.\n\nE.g. Menus, recipes, and food journal entries\n\nWhen ready, tap 'Scan Image' to analyze nutrition."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose or Take Photo", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.borderColor = UIColor.systemGray4.cgColor
        iv.layer.borderWidth = 1
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        return iv
    }()
    
    private let scanImageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Scan Image", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.isEnabled = false // disabled until photo selected
        return btn
    }()
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.titleLabel?.textAlignment = .center
        return btn
    }()
    
    private var selectedImageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Upload Image"
        
        setUpImageUploadSubviews()
        setUpImageUploadConstraints()
        
        selectPhotoButton.addTarget(self, action: #selector(selectPhotoTapped), for: .touchUpInside)
        scanImageButton.addTarget(self, action: #selector(scanImageTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    private func setUpImageUploadSubviews() {
        view.addSubview(instructionsLabel)
        view.addSubview(selectPhotoButton)
        view.addSubview(imageView)
        view.addSubview(scanImageButton)
        view.addSubview(cancelButton)
    }
    
    private func setUpImageUploadConstraints() {
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        selectPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scanImageButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            instructionsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            selectPhotoButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 30),
            selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.topAnchor.constraint(equalTo: selectPhotoButton.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 250),
            
            scanImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            scanImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: scanImageButton.bottomAnchor, constant: 15),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
 
extension ImageUploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc private func selectPhotoTapped() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = false
        
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
                picker.sourceType = .camera
                self.present(picker, animated: true)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func scanImageTapped() {
        guard let imageData = selectedImageData else { return }
        delegate?.imageUploadViewController(self, didScanImage: imageData)
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.imageUploadControllerDidCancel(self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        imageView.image = image
        selectedImageData = imageData
        scanImageButton.isEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
