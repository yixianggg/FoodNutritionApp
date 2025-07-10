//
//  FoodListViewModelDelegate.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 27/6/25.
//

import Foundation

protocol FoodListViewModelDelegate: AnyObject {
    func didUpdateFoods()
    func didFailWithError(_ errorMessage: String)
    func didChangeLoadingState(isLoading: Bool)
}
