//
//  FoodListCell.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 2/7/25.
//

import Foundation
import UIKit

class FoodListCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let caloriesLabel = UILabel()
    private let quantityTextField = UITextField()
    private let quantityLabel = UILabel()
    
    // Closure to notify quantity changes
    var onQuantityFieldDidBeginEditing: (() -> Void)?
    var onQuantityFieldDidEndEditing: ((Double) -> Void)?
    var onQuantityFieldEdited: ((Double) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpFoodListCellUI()
        setUpFoodListCellConstraints()
        quantityTextField.delegate = self
        
        quantityTextField.addTarget(self, action: #selector(quantityTextFieldDidChange), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpFoodListCellUI() {
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        caloriesLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        caloriesLabel.textColor = .secondaryLabel
        
        quantityTextField.borderStyle = .roundedRect
        quantityTextField.keyboardType = .numberPad
        quantityTextField.textAlignment = .center
        quantityTextField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        quantityLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        quantityLabel.textColor = .secondaryLabel
        quantityLabel.text = "g"
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(caloriesLabel)
        contentView.addSubview(quantityTextField)
        contentView.addSubview(quantityLabel)
    }
    
    private func setUpFoodListCellConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        caloriesLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityTextField.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            caloriesLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            //quantityTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            quantityTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            quantityTextField.widthAnchor.constraint(equalToConstant: 60),
            
            quantityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            quantityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            caloriesLabel.trailingAnchor.constraint(lessThanOrEqualTo: quantityTextField.leadingAnchor, constant: -12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: caloriesLabel.leadingAnchor, constant: -16),
            quantityTextField.trailingAnchor.constraint(lessThanOrEqualTo: quantityLabel.leadingAnchor, constant: -8)
        ])
    }
    
    func configureCell(with food: FoodNutrition) {
        nameLabel.text = food.name.capitalized
        caloriesLabel.text = "\(Int(food.scaledCalories)) cal"
        accessoryType = .disclosureIndicator
        
        quantityTextField.text = "\(Int(food.mutableServingSize))"
    }
    
    @objc private func quantityTextFieldDidChange() {
        if let text = quantityTextField.text, let quantity = Double(text), quantity > 0 {
            onQuantityFieldEdited?(quantity)
        } else {
            // Reset to default if invalid
            onQuantityFieldEdited?(0)
        }
    }
    
    func updateCalories(_ scaledCalories: Int) {
        caloriesLabel.text = "\(scaledCalories) cal"
    }
}

extension FoodListCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onQuantityFieldDidBeginEditing?()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let quantity = Double(text), quantity > 0 else {
            // Reset to default if invalid
            textField.text = "100"
            onQuantityFieldDidEndEditing?(100)
            return
        }
        onQuantityFieldDidEndEditing?(quantity)
    }
}
