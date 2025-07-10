//
//  CalorieNinjasAPI.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 27/6/25.
//

import Foundation

class CalorieNinjasAPI: CalorieNinjasAPIProtocol {
    private let apiClient = APIClient()
    private let apiKey: String
    private let fetchFoodsURL = "https://api.calorieninjas.com/v1/nutrition"
    private let fetchNutritionFromImageURL = "https://api.calorieninjas.com/v1/imagetextnutrition"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func fetchFoods(for query: String, completion: @escaping (Result<FoodsResponse, APIError>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let urlString = "\(fetchFoodsURL)?query=\(encodedQuery)"
        let headers = ["X-API-Key": apiKey]
        
        apiClient.get(urlString: urlString, headers: headers, completion: completion)
    }
    
    func fetchNutritionFromImage(for imageData: Data, completion: @escaping (Result<FoodsResponse, APIError>) -> Void) {
        let headers = ["X-API-Key": apiKey]
        
        apiClient.postMultipart(urlString: fetchNutritionFromImageURL, headers: headers, imageData: imageData, completion: completion)
    }
}
