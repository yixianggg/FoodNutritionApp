//
//  AddFoodViewControllerDelegate.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 2/7/25.
//

import UIKit

protocol AddFoodViewControllerDelegate: AnyObject {
    func addFoodViewController(_ controller: AddFoodViewController, didAddFood foodName: String, date: Date)
    func addFoodViewControllerDidCancel(_ controller: AddFoodViewController)
}
