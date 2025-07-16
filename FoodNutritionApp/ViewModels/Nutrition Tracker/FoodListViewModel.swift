//
//  FoodListViewModel.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 27/6/25.
//

import Foundation

class FoodListViewModel {
    
    weak var delegate: FoodListViewModelDelegate?
    
    private(set) var nutritionService: FoodServiceProtocol
    private(set) var storageService: FoodStorageServiceProtocol
    
    private(set) var dates: [Date] = [] // ordered list of dates (sections)
    private var foodsByDate: [Date: [FoodNutrition]] = [:] // foods grouped by date
    private var sectionsForSaving: [FoodSection] {
        return dates.compactMap { date in
            if let foods = foodsByDate[date], !foods.isEmpty {
                return FoodSection(date: date, foods: foods)
            } else {
                // Skip dates with no foods (empty arrays or nil)
                return nil
            }
        }
    }
    
    init(foodService: FoodServiceProtocol, storageService: FoodStorageServiceProtocol) {
        self.nutritionService = foodService
        self.storageService = storageService
    }
    
    func searchFoods(query: String, for date: Date? = nil) {
        guard !query.isEmpty else {
            delegate?.didFailWithError("Search query cannot be empty")
            return
        }
        
        delegate?.didChangeLoadingState(isLoading: true)
        
        nutritionService.fetchFoods(for: query) { [ weak self ] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.items.count == 0 {
                        self?.delegate?.didFailWithError("Unable to find food")
                        self?.delegate?.didChangeLoadingState(isLoading: false)
                    }
                    
                    let targetDate = self?.stripTime(from: date ?? Date()) ?? Date()
                    
                    for item in response.items {
                        self?.addFood(item, for: targetDate)
                    }
                case .failure(let error):
                    self?.delegate?.didFailWithError(self?.errorMessage(for: error) ?? "Unknown error")
                    self?.delegate?.didChangeLoadingState(isLoading: false)
                }
            }
        }
    }
    
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
    
    func load() {
        do {
            let savedSections = try storageService.loadFoodSections()
            foodsByDate = Dictionary(uniqueKeysWithValues: savedSections.map { ($0.date, $0.foods) })
            dates = savedSections.map { $0.date }
            dates.sort(by: >)
        } catch {
            print("Failed to load food sections: \(error)")
            let today = stripTime(from: Date())
            dates = [today]
            foodsByDate[today] = []
        }
        prepareSectionItems()
    }

    func save() {
        do {
            try storageService.saveFoodSections(sectionsForSaving)
            print("Food sections saved successfully.")
        } catch {
            print("Failed to save food sections: \(error)")
        }
    }
    
//    func load() {
//        let defaults = UserDefaults.standard
//        
//        guard let savedData = defaults.data(forKey: "foodSections") else {
//            // No saved data, initialize with today only
//            let today = stripTime(from: Date())
//            dates = [today]
//            foodsByDate[today] = []
//            return
//        }
//        
//        let jsonDecoder = JSONDecoder()
//        
//        do {
//            let savedSections = try jsonDecoder.decode([FoodSection].self, from: savedData)
//            //print(savedSections)
//            foodsByDate = Dictionary(uniqueKeysWithValues: savedSections.map { ($0.date, $0.foods) })
//            
//            for (date, foods) in foodsByDate {
//                print("Date: \(date)")
//                for food in foods {
//                    print("  \(food.name): \(food.mutableServingSize)")
//                }
//            }
//            
//            dates = savedSections.map { $0.date }
//            dates.sort(by: >)
//            print(dates)
//        } catch {
//            print("Failed to load food sections: \(error)")
//            
//            let today = stripTime(from: Date())
//            dates = [today]
//            foodsByDate[today] = []
//        }
//        
//        prepareSectionItems()
//    }
//    
//    func save() {
//        let jsonEncoder = JSONEncoder()
//        do {
//            let data = try jsonEncoder.encode(sectionsForSaving)
//            // For debugging: print JSON string representation
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Saving food sections JSON:\n\(jsonString)")
//            } else {
//                print("Failed to convert saved data to string for debugging")
//            }
//            UserDefaults.standard.set(data, forKey: "foodSections")
//            print("Food sections saved successfully.")
//        } catch {
//            print("Failed to save food sections: \(error)")
//        }
//    }
    
    func deleteFood(at indexPath: IndexPath) {
        let date = dates[indexPath.section]
        let foodIndex = indexPath.row - 1
        guard var foods = foodsByDate[date], foodIndex < foods.count else { return }
        
        foods.remove(at: foodIndex)
        foodsByDate[date] = foods
        

        if foods.isEmpty {
            foodsByDate.removeValue(forKey: date)
            dates.remove(at: indexPath.section)
        }
        
        prepareSectionItems()
        save()
        
        delegate?.didUpdateFoods()
    }
    
    func updateQuantity(at indexPath: IndexPath, quantity: Double) {
        let dateIndex = indexPath.section
        let foodIndex = indexPath.row - 1
        
        guard dateIndex >= 0 && dateIndex < dates.count else { return }
        
        let date = dates[dateIndex]
        guard var foods = foodsByDate[date], foodIndex >= 0 && foodIndex < foods.count else { return }
        
        foods[foodIndex].mutableServingSize = quantity
        foodsByDate[date] = foods
        
        prepareSectionItems()
        save()
        
        delegate?.didUpdateFoods()
    }
    
    func getScaledCalories(at indexPath: IndexPath, quantity: Double) -> Int {
        let dateIndex = indexPath.section
        let foodIndex = indexPath.row - 1
        
        guard dateIndex >= 0 && dateIndex < dates.count else { return 0 }
        
        let date = dates[dateIndex]
        guard var foods = foodsByDate[date], foodIndex >= 0 && foodIndex < foods.count else { return 0 }
        
        foods[foodIndex].mutableServingSize = quantity
        
        return Int(foods[foodIndex].scaledCalories)
    }
    
    private func stripTime(from date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    func addFood(_ food: FoodNutrition, for date: Date) {
        let normalizedDate = stripTime(from: date)
        
        if !dates.contains(normalizedDate) {
            dates.append(normalizedDate)
            dates.sort(by: >) // keep sorted ascending
            foodsByDate[normalizedDate] = []
        }
        
        foodsByDate[normalizedDate]?.insert(food, at: 0)
        
        prepareSectionItems()
        save()
        
        delegate?.didUpdateFoods()
        delegate?.didChangeLoadingState(isLoading: false)
    }
    
    func numberOfSections() -> Int {
        return dates.count
    }

    func food(at indexPath: IndexPath) -> FoodNutrition? {
        let foodIndex = indexPath.row - 1
        guard indexPath.section >= 0 && indexPath.section < dates.count else { return nil }
        let date = dates[indexPath.section]
        guard let foods = foodsByDate[date], foodIndex < foods.count else { return nil }
        return foods[foodIndex]
    }

    func titleForSection(_ section: Int) -> String? {
        guard section >= 0 && section < dates.count else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dates[section])
    }
    
//    func getNutrientsForSection(for section: Int) -> [NutritionSectionFooterView.NutrientInfo] {
//        let date = dates[section]
//        let foods = foodsByDate[date] ?? []
//        let totalCalories = foods.reduce(0) { $0 + $1.scaledCalories }
//        let totalProtein = foods.reduce(0) { $0 + $1.scaledProtein }
//        let totalFat = foods.reduce(0) { $0 + $1.scaledFatTotal }
//        let totalCarbs = foods.reduce(0) { $0 + $1.scaledCarbohydrates }
//        let totalSugar = foods.reduce(0) { $0 + $1.scaledSugar }
//        let totalCholesterol = foods.reduce(0) { $0 + $1.scaledCholesterol }
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
    
    private(set) var sectionItems: [[FoodSectionItem]] = []

    func prepareSectionItems() {
        sectionItems = dates.map { date in
            let foods = foodsByDate[date] ?? []
            
            // Create food items
            var items: [FoodSectionItem] = foods.map { .food($0) }
            
            // Calculate totals for summary
            let totalCalories = foods.reduce(0) { $0 + $1.scaledCalories }
            let totalProtein = foods.reduce(0) { $0 + $1.scaledProtein }
            let totalFat = foods.reduce(0) { $0 + $1.scaledFatTotal }
            let totalCarbs = foods.reduce(0) { $0 + $1.scaledCarbohydrates }
            let totalSugar = foods.reduce(0) { $0 + $1.scaledSugar }
            let totalCholesterol = foods.reduce(0) { $0 + $1.scaledCholesterol }
            
            let nutrients = [
                NutrientInfo(name: "Calories", value: "\(Int(totalCalories)) cal", color: .systemRed),
                NutrientInfo(name: "Protein", value: String(format: "%.1f g", totalProtein), color: .systemBlue),
                NutrientInfo(name: "Fat", value: String(format: "%.1f g", totalFat), color: .systemOrange),
                NutrientInfo(name: "Carbs", value: String(format: "%.1f g", totalCarbs), color: .systemGreen),
                NutrientInfo(name: "Sugar", value: String(format: "%.1f g", totalSugar), color: .systemPink),
                NutrientInfo(name: "Cholesterol", value: String(format: "%.1f mg", totalCholesterol), color: .systemPurple)
            ]
            
            // Append summary item
            items.insert(.summary(SummaryData(nutrients: nutrients)), at: 0)
            
            return items
        }
    }

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
