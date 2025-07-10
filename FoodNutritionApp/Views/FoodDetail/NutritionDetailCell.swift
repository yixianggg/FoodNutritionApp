//
//  NutritionDetailCell.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 1/7/25.
//

import Foundation
import UIKit

class NutritionDetailCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let valueLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpDetailCellUI()
        setUpDetailCellConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpDetailCellUI() {
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .right
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(valueLabel)
    }
    
    private func setUpDetailCellConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -8)
        ])
    }
    
    func configureCell(with detail: (name: String, value: String)) {
        nameLabel.text = detail.name
        valueLabel.text = detail.value
        selectionStyle = .none
    }
}
