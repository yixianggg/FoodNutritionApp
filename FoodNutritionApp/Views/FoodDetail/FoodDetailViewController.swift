//
//  FoodDetailViewController.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 1/7/25.
//

import Foundation
import UIKit

class FoodDetailViewController: UIViewController {
    
    weak var delegate: FoodDetailViewControllerDelegate?
    
    private let viewModel: FoodDetailViewModel
    
    // private let food: FoodNutrition
    private let isAddButtonShown: Bool
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // private var nutritionDetails: [(name: String, value: String)] = []
    
    private let addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add Food to Tracker", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.titleLabel?.textAlignment = .center
        return btn
    }()
    
    private var tableViewBottomToButtonTopConstraint: NSLayoutConstraint!
    private var tableViewBottomToViewBottomConstraint: NSLayoutConstraint!
    
    init(viewModel: FoodDetailViewModel, withAddButton: Bool = false) {
        // self.food = food
        self.viewModel = viewModel
        self.isAddButtonShown = withAddButton
        super.init(nibName: nil, bundle: nil)
        self.title = "\(viewModel.foodName) (\(viewModel.servingSizeText))"
        self.viewModel.delegate = self
        //prepareNutritionDetails()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    private func prepareNutritionDetails() {
//        nutritionDetails = [
//            ("Calories", "\(Int(food.scaledCalories)) cal"),
//            ("Protein", String(format: "%.1f g", food.scaledProtein)),
//            ("Total Fat", String(format: "%.1f g", food.scaledFatTotal)),
//            ("Saturated Fat", String(format: "%.1f g", food.scaledFatSaturated)),
//            ("Carbohydrates", String(format: "%.1f g", food.scaledCarbohydrates)),
//            ("Fiber", String(format: "%.1f g", food.scaledFiber)),
//            ("Sugar", String(format: "%.1f g", food.scaledSugar)),
//            ("Sodium", String(format: "%.1f mg", food.scaledSodium)),
//            ("Potassium", String(format: "%.1f mg", food.scaledPotassium)),
//            ("Cholesterol", String(format: "%.1f mg", food.scaledCholesterol))
//        ]
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFoodDetailUI()
        setUpFoodDetailConstraints()
        setUpFoodDetailDelegates()
    }
    
    private func setUpFoodDetailUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(addButton)
        
        tableView.register(NutritionDetailCell.self, forCellReuseIdentifier: "NutritionDetailCell")
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func setUpFoodDetailConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        tableViewBottomToButtonTopConstraint = tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20)
        tableViewBottomToViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        if isAddButtonShown {
            addButton.isHidden = false
            tableViewBottomToViewBottomConstraint.isActive = false
            tableViewBottomToButtonTopConstraint.isActive = true
        } else {
            addButton.isHidden = true
            tableViewBottomToButtonTopConstraint.isActive = false
            tableViewBottomToViewBottomConstraint.isActive = true
        }
    }
    
    private func setUpFoodDetailDelegates() {
        tableView.dataSource = self
    }
    
    @objc private func addButtonTapped() {
        delegate?.foodDetailViewController(self, didAddFood: viewModel.food)
    }
}

extension FoodDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.nutritionDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NutritionDetailCell", for: indexPath) as? NutritionDetailCell else {
            fatalError("Unable to dequeue NutritionDetailCell")
        }
        
        let detail = viewModel.nutritionDetails[indexPath.row]
        cell.configureCell(with: detail)
        
        return cell
    }
}

extension FoodDetailViewController: FoodDetailViewModelDelegate {
    func foodDetailViewModelDidUpdateData(_ viewModel: FoodDetailViewModel) {
        tableView.reloadData()
    }
    
    func foodDetailViewModel(_ viewModel: FoodDetailViewModel, didFailWithError error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
