//
//  AddFoodViewController.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 2/7/25.
//

import Foundation
import UIKit

class AddFoodViewController: UIViewController {
    
    weak var delegate: AddFoodViewControllerDelegate?
    
    private let foodTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter meal name"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your meal with its amount!\n(whole numbers in g/kg/lbs)\n\nE.g. 300g of chicken breast with 1kg of potatoes"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .wheels
        dp.maximumDate = Date()
        return dp
    }()
    
    private let addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.titleLabel?.textAlignment = .center
        return btn
    }()
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.titleLabel?.textAlignment = .center
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Track Your Meal Nutrition"
        
        setupAddFoodSubviews()
        setupAddFoodConstraints()
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        // Automatically focus text field
        foodTextField.becomeFirstResponder()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupAddFoodSubviews() {
        view.addSubview(foodTextField)
        view.addSubview(instructionLabel)
        view.addSubview(datePicker)
        view.addSubview(addButton)
        view.addSubview(cancelButton)
    }
    
    private func setupAddFoodConstraints() {
        foodTextField.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            foodTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            foodTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            foodTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            foodTextField.heightAnchor.constraint(equalToConstant: 44),
            
            instructionLabel.topAnchor.constraint(equalTo: foodTextField.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: foodTextField.leadingAnchor),
            instructionLabel.trailingAnchor.constraint(equalTo: foodTextField.trailingAnchor),
            
            datePicker.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 10),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            addButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 5),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 15),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func addButtonTapped() {
        guard let foodName = foodTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !foodName.isEmpty else {
            // Show alert or shake text field to indicate error
            let alert = UIAlertController(title: "Error", message: "Please enter a meal name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        delegate?.addFoodViewController(self, didAddFood: foodName, date: datePicker.date)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.addFoodViewControllerDidCancel(self)
    }
}
