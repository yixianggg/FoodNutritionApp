//
//  ImageNutritionViewModelDelegate.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 2/7/25.
//

import Foundation

protocol ImageNutritionViewModelDelegate: AnyObject {
    func didUpdateNutritionItems()
    func didFailWithError(_ errorMessage: String)
    func didChangeLoadingState(isLoading: Bool)
}
