//
//  FoodDetailViewModel.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 8/7/25.
//

import Foundation

class FoodDetailViewModel {
    
    weak var delegate: FoodDetailViewModelDelegate?
    
    private(set) var food: FoodNutrition
    
    private(set) var nutritionDetails: [(name: String, value: String)] = []
    
    var foodName: String {
        food.name.capitalized
    }
    
    var servingSizeText: String {
        String(format: "%.0f g", food.mutableServingSize)
    }
    
    init(food: FoodNutrition) {
            self.food = food
            prepareNutritionDetails()
        }
    
    private func prepareNutritionDetails() {
        nutritionDetails = [
            ("Calories", "\(Int(food.scaledCalories)) cal"),
            ("Protein", String(format: "%.1f g", food.scaledProtein)),
            ("Total Fat", String(format: "%.1f g", food.scaledFatTotal)),
            ("Saturated Fat", String(format: "%.1f g", food.scaledFatSaturated)),
            ("Carbohydrates", String(format: "%.1f g", food.scaledCarbohydrates)),
            ("Fiber", String(format: "%.1f g", food.scaledFiber)),
            ("Sugar", String(format: "%.1f g", food.scaledSugar)),
            ("Sodium", String(format: "%.1f mg", food.scaledSodium)),
            ("Potassium", String(format: "%.1f mg", food.scaledPotassium)),
            ("Cholesterol", String(format: "%.1f mg", food.scaledCholesterol))
        ]
        
        delegate?.foodDetailViewModelDidUpdateData(self)
    }
}
