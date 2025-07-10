//
//  NutritionSectionFooterView.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 4/7/25.
//

import Foundation
import UIKit

class NutritionSectionFooterView: UITableViewHeaderFooterView {
    
    private let verticalStackView = UIStackView()
    private let topHorizontalStackView = UIStackView()
    private let bottomHorizontalStackView = UIStackView()
    
    struct NutrientInfo {
        let name: String
        let value: String
        let color: UIColor
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStackView() {
        // Configure vertical stack view
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8
        verticalStackView.alignment = .center
        verticalStackView.distribution = .fill
        
        // Configure horizontal stack views
        [topHorizontalStackView, bottomHorizontalStackView].forEach { stack in
            stack.axis = .horizontal
            stack.alignment = .center
            stack.distribution = .equalSpacing
            stack.spacing = 12
            verticalStackView.addArrangedSubview(stack)
        }
        
        contentView.addSubview(verticalStackView)
        
        setUpFooterConstraints()
    }
    
    private func setUpFooterConstraints() {
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configureFooter(with nutrients: [NutrientInfo]) {
        // Remove old views
        topHorizontalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        bottomHorizontalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Split nutrients into two groups of 3
        let topNutrients = nutrients.prefix(3)
        let bottomNutrients = nutrients.dropFirst(3).prefix(3)
        
        func createNutrientView(_ nutrient: NutrientInfo) -> UIView {
            let container = UIStackView()
            container.axis = .horizontal
            container.alignment = .center
            container.spacing = 6
            
            let dot = UIView()
            dot.backgroundColor = nutrient.color
            dot.layer.cornerRadius = 5
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 10).isActive = true
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .secondaryLabel
            label.text = "\(nutrient.name): \(nutrient.value)"
            label.setContentHuggingPriority(.defaultLow, for: .horizontal)  // Allow flexible width
            
            container.addArrangedSubview(dot)
            container.addArrangedSubview(label)
            
            return container
        }
        
        topNutrients.forEach { nutrient in
            topHorizontalStackView.addArrangedSubview(createNutrientView(nutrient))
        }
        
        bottomNutrients.forEach { nutrient in
            bottomHorizontalStackView.addArrangedSubview(createNutrientView(nutrient))
        }
    }
}
