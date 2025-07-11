//
//  FoodStorageService.swift
//  FoodNutritionApp
//
//  Created by ByteDance on 11/7/25.
//

import Foundation

class FoodStorageService: FoodStorageServiceProtocol {
    
    private let userDefaultsKey = "foodSections"
    private let defaults = UserDefaults.standard
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    func loadFoodSections() throws -> [FoodSection] {
        guard let savedData = defaults.data(forKey: userDefaultsKey) else {
            return []
        }
        return try jsonDecoder.decode([FoodSection].self, from: savedData)
    }
    
    func saveFoodSections(_ sections: [FoodSection]) throws {
        let data = try jsonEncoder.encode(sections)
        defaults.set(data, forKey: userDefaultsKey)
    }
}
