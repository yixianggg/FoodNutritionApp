//
//  FoodNutrition.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 27/6/25.
//

import Foundation

struct FoodNutrition: Codable {
    let sugar_g: Double
    let fiber_g: Double
    let serving_size_g: Double
    let sodium_mg: Double
    let name: String
    let potassium_mg: Double
    let fat_saturated_g: Double
    let fat_total_g: Double
    let calories: Double
    let cholesterol_mg: Double
    let protein_g: Double
    let carbohydrates_total_g: Double
    
    // Private backing store for mutable serving size
    private var _mutableServingSize: Double? = nil
    
    // Computed property: uses _mutableServingSize if set, else defaults to serving_size_g
    var mutableServingSize: Double {
        get {
            return _mutableServingSize ?? serving_size_g
        }
        set {
            _mutableServingSize = newValue
        }
    }
    
    // Computed properties to scale nutrients based on userServingSize
    var scaledSugar: Double {
        return (sugar_g / serving_size_g) * mutableServingSize
    }
    var scaledFiber: Double {
        return (fiber_g / serving_size_g) * mutableServingSize
    }
    var scaledSodium: Double {
        return (sodium_mg / serving_size_g) * mutableServingSize
    }
    var scaledPotassium: Double {
        return (potassium_mg / serving_size_g) * mutableServingSize
    }
    var scaledFatSaturated: Double {
        return (fat_saturated_g / serving_size_g) * mutableServingSize
    }
    var scaledFatTotal: Double {
        return (fat_total_g / serving_size_g) * mutableServingSize
    }
    var scaledCalories: Double {
        return (calories / serving_size_g) * mutableServingSize
    }
    var scaledCholesterol: Double {
        return (cholesterol_mg / serving_size_g) * mutableServingSize
    }
    var scaledProtein: Double {
        return (protein_g / serving_size_g) * mutableServingSize
    }
    var scaledCarbohydrates: Double {
        return (carbohydrates_total_g / serving_size_g) * mutableServingSize
    }
    
    private enum CodingKeys: String, CodingKey {
         case sugar_g, fiber_g, serving_size_g, sodium_mg, name, potassium_mg,
              fat_saturated_g, fat_total_g, calories, cholesterol_mg,
              protein_g, carbohydrates_total_g
         case mutableServingSize = "_mutableServingSize"
    }
    
     // Custom decoder to decode _mutableServingSize
     init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         sugar_g = try container.decode(Double.self, forKey: .sugar_g)
         fiber_g = try container.decode(Double.self, forKey: .fiber_g)
         serving_size_g = try container.decode(Double.self, forKey: .serving_size_g)
         sodium_mg = try container.decode(Double.self, forKey: .sodium_mg)
         name = try container.decode(String.self, forKey: .name)
         potassium_mg = try container.decode(Double.self, forKey: .potassium_mg)
         fat_saturated_g = try container.decode(Double.self, forKey: .fat_saturated_g)
         fat_total_g = try container.decode(Double.self, forKey: .fat_total_g)
         calories = try container.decode(Double.self, forKey: .calories)
         cholesterol_mg = try container.decode(Double.self, forKey: .cholesterol_mg)
         protein_g = try container.decode(Double.self, forKey: .protein_g)
         carbohydrates_total_g = try container.decode(Double.self, forKey: .carbohydrates_total_g)
         _mutableServingSize = try container.decodeIfPresent(Double.self, forKey: .mutableServingSize)
     }
    
     // Custom encoder to encode _mutableServingSize
     func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(sugar_g, forKey: .sugar_g)
         try container.encode(fiber_g, forKey: .fiber_g)
         try container.encode(serving_size_g, forKey: .serving_size_g)
         try container.encode(sodium_mg, forKey: .sodium_mg)
         try container.encode(name, forKey: .name)
         try container.encode(potassium_mg, forKey: .potassium_mg)
         try container.encode(fat_saturated_g, forKey: .fat_saturated_g)
         try container.encode(fat_total_g, forKey: .fat_total_g)
         try container.encode(calories, forKey: .calories)
         try container.encode(cholesterol_mg, forKey: .cholesterol_mg)
         try container.encode(protein_g, forKey: .protein_g)
         try container.encode(carbohydrates_total_g, forKey: .carbohydrates_total_g)
         try container.encodeIfPresent(_mutableServingSize, forKey: .mutableServingSize)
     }
}
 
