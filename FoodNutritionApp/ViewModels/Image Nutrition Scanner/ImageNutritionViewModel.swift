//
//  ImageNutritionViewModel.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 2/7/25.
//

import Foundation

class ImageNutritionViewModel {
    weak var delegate: ImageNutritionViewModelDelegate?
    
    private let nutritionService: FoodServiceProtocol
    
    private(set) var nutritionItems: [FoodNutrition] = []
    
    init(service: FoodServiceProtocol) {
        self.nutritionService = service
    }
    
    func fetchNutritionFromImage(_ imageData: Data) {
        delegate?.didChangeLoadingState(isLoading: true)
        nutritionService.fetchNutritionFromImage(for: imageData) { [weak self] result in
            DispatchQueue.main.async {
                self?.delegate?.didChangeLoadingState(isLoading: false)
                switch result {
                case .success(let response):
                    if response.items.count == 0 {
                        self?.delegate?.didFailWithError("Unable to identify food/beverage text in scanned image")
                    }
                    self?.setNutritionItems(from: response.items)
                    self?.delegate?.didUpdateNutritionItems()
                case .failure(let error):
                    self?.delegate?.didFailWithError(self?.errorMessage(for: error) ?? "Unknown error")
                }
            }
        }
    }
    
    func updateQuantity(at index: Int, quantity: Double) {
        let foodIndex = index - 1
        
        guard foodIndex >= 0 && foodIndex < nutritionItems.count else { return }
        nutritionItems[foodIndex].mutableServingSize = quantity
        prepareSectionItems()
        delegate?.didUpdateNutritionItems()
    }
    
    func getScaledCalories(at index: Int, quantity: Double) -> Int {
        let foodIndex = index - 1
        
        guard foodIndex >= 0 && foodIndex < nutritionItems.count else { return 0 }
        
        nutritionItems[foodIndex].mutableServingSize = quantity
        
        return Int(nutritionItems[foodIndex].scaledCalories)
    }
    
//    func getNutrientsForTable() -> [NutritionSectionFooterView.NutrientInfo] {
//        let totalCalories = nutritionItems.reduce(0) { $0 + $1.scaledCalories }
//        let totalProtein = nutritionItems.reduce(0) { $0 + $1.scaledProtein }
//        let totalFat = nutritionItems.reduce(0) { $0 + $1.scaledFatTotal }
//        let totalCarbs = nutritionItems.reduce(0) { $0 + $1.scaledCarbohydrates }
//        let totalSugar = nutritionItems.reduce(0) { $0 + $1.scaledSugar }
//        let totalCholesterol = nutritionItems.reduce(0) { $0 + $1.scaledCholesterol }
//        
//        let nutrients = [
//            NutritionSectionFooterView.NutrientInfo(name: "Calories", value: "\(Int(totalCalories)) cal", color: .systemRed),
//            NutritionSectionFooterView.NutrientInfo(name: "Protein", value: String(format: "%.1f g", totalProtein), color: .systemBlue),
//            NutritionSectionFooterView.NutrientInfo(name: "Carbs", value: String(format: "%.1f g", totalCarbs), color: .systemGreen),
//            NutritionSectionFooterView.NutrientInfo(name: "Cholesterol", value: String(format: "%.1f mg", totalCholesterol), color: .systemPurple),
//            NutritionSectionFooterView.NutrientInfo(name: "Sugar", value: String(format: "%.1f g", totalSugar), color: .systemYellow),
//            NutritionSectionFooterView.NutrientInfo(name: "Fat", value: String(format: "%.1f g", totalFat), color: .systemOrange)
//        ]
//        
//        return nutrients
//    }
    
    private func errorMessage(for error: APIError) -> String? {
        switch error {
        case .invalidURL:
            return "Invalid API URL"
        case .requestFailed(let description):
            return "Network error: \(description)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingFailed:
            return "Failed to process data"
        }
    }
    
    private func setNutritionItems(from apiItems: [FoodNutrition]) {
        nutritionItems = apiItems.map { item in
            var mutableItem = item
            mutableItem.mutableServingSize = 100.0 // default quantity
            return mutableItem
        }
        
        prepareSectionItems()
    }
    
    private(set) var sectionItems: [[FoodSectionItem]] = []

    private func prepareSectionItems() {
        var items: [FoodSectionItem] = nutritionItems.map { .food($0) }
        
        // Calculate totals for summary
        let totalCalories = nutritionItems.reduce(0) { $0 + $1.scaledCalories }
        let totalProtein = nutritionItems.reduce(0) { $0 + $1.scaledProtein }
        let totalFat = nutritionItems.reduce(0) { $0 + $1.scaledFatTotal }
        let totalCarbs = nutritionItems.reduce(0) { $0 + $1.scaledCarbohydrates }
        let totalSugar = nutritionItems.reduce(0) { $0 + $1.scaledSugar }
        let totalCholesterol = nutritionItems.reduce(0) { $0 + $1.scaledCholesterol }
        
        let nutrients = [
            NutrientInfo(name: "Calories", value: "\(Int(totalCalories)) cal", color: .systemRed),
            NutrientInfo(name: "Protein", value: String(format: "%.1f g", totalProtein), color: .systemBlue),
            NutrientInfo(name: "Carbs", value: String(format: "%.1f g", totalCarbs), color: .systemGreen),
            NutrientInfo(name: "Cholesterol", value: String(format: "%.1f mg", totalCholesterol), color: .systemPurple),
            NutrientInfo(name: "Sugar", value: String(format: "%.1f g", totalSugar), color: .systemYellow),
            NutrientInfo(name: "Fat", value: String(format: "%.1f g", totalFat), color: .systemOrange)
        ]
        
        let summary = SummaryData(nutrients: nutrients)
        items.insert(.summary(summary), at: 0)
        sectionItems = [items]
    }

    // Update your data source methods to use sectionItems
    func numberOfRows(in section: Int) -> Int {
        guard section < sectionItems.count else { return 0 }
        return sectionItems[section].count
    }

    func item(at indexPath: IndexPath) -> FoodSectionItem? {
        guard indexPath.section < sectionItems.count,
              indexPath.row < sectionItems[indexPath.section].count else { return nil }
        return sectionItems[indexPath.section][indexPath.row]
    }
}
