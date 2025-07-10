//
//  ImageNutritionViewControllerDelegate.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 4/7/25.
//

import Foundation

protocol ImageNutritionViewControllerDelegate: AnyObject {
    func imageNutritionViewController(_ controller: ImageNutritionViewController, didAddFoodFromDetail food: FoodNutrition)
}
