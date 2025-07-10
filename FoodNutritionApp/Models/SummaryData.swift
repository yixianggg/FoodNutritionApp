//
//  SummaryData.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 7/7/25.
//

import Foundation
import UIKit

struct NutrientInfo {
    let name: String
    let value: String
    let color: UIColor
}

struct SummaryData {
    let nutrients: [NutrientInfo]
}
