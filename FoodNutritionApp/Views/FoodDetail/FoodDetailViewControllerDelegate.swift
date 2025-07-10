//
//  FoodDetailViewControllerDelegate.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 4/7/25.
//

import UIKit

protocol FoodDetailViewControllerDelegate: AnyObject {
    func foodDetailViewController(_ controller: FoodDetailViewController, didAddFood food: FoodNutrition)
}
