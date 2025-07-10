//
//  ImageUploadViewControllerDelegate.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 3/7/25.
//

import Foundation
import UIKit

protocol ImageUploadViewControllerDelegate: AnyObject {
    func imageUploadViewController(_ controller: ImageUploadViewController, didScanImage imageData: Data)
    func imageUploadControllerDidCancel(_ controller: ImageUploadViewController)
}
