//
//  FoodDetailViewModelDelegate.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 8/7/25.
//

import Foundation

protocol FoodDetailViewModelDelegate: AnyObject {
    func foodDetailViewModelDidUpdateData(_ viewModel: FoodDetailViewModel)
    func foodDetailViewModel(_ viewModel: FoodDetailViewModel, didFailWithError error: String)
}
