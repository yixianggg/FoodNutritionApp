//
//  CalorieNinjasAPIProtocol.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 27/6/25.
//

import Foundation

protocol CalorieNinjasAPIProtocol {
    func fetchFoods(for query: String, completion: @escaping (Result<FoodsResponse, APIError>) -> Void)
    
    func fetchNutritionFromImage(for imageData: Data, completion: @escaping (Result<FoodsResponse, APIError>) -> Void)
}
