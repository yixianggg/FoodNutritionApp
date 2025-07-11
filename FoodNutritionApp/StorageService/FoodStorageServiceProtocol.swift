//
//  FoodStorageServiceProtocol.swift
//  FoodNutritionApp
//
//  Created by ByteDance on 11/7/25.
//

import Foundation

protocol FoodStorageServiceProtocol {
    func loadFoodSections() throws -> [FoodSection]
    func saveFoodSections(_ sections: [FoodSection]) throws
}
