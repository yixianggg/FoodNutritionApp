//
//  FoodSection.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 2/7/25.
//

import Foundation

struct FoodSection: Codable {
    let date: Date
    var foods: [FoodNutrition]
}
