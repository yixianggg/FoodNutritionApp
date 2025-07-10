//
//  ImageNutritionViewController.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 2/7/25.
//

import Foundation
import UIKit

class ImageNutritionViewController: UIViewController {
    
    weak var delegate: ImageNutritionViewControllerDelegate?
    private weak var activeCell: UITableViewCell?

    private let viewModel: ImageNutritionViewModel
    
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    init(viewModel: ImageNutritionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
        self.title = "Nutrition Results per 100 g (Default)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupDelegates()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        activityIndicator.hidesWhenStopped = true
        
        tableView.register(FoodListCell.self, forCellReuseIdentifier: "FoodListCell")
        tableView.register(SummaryCell.self, forCellReuseIdentifier: "SummaryCell")
//        tableView.register(NutritionSectionFooterView.self, forHeaderFooterViewReuseIdentifier: "NutritionSectionFooterView")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupDelegates() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardHeight = keyboardFrame.height
        
        // Adjust table view content inset and scroll indicator inset
        var contentInset = tableView.contentInset
        contentInset.bottom = keyboardHeight
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
        
        // Scroll the active cell into view
        if let activeCell = activeCell {
            if let indexPath = tableView.indexPath(for: activeCell) {
                // Use indexPath as needed
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // Reset content inset and scroll indicator inset
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }
}

extension ImageNutritionViewController: ImageNutritionViewModelDelegate {
    func didUpdateNutritionItems() {
        tableView.reloadData()
    }
    
    func didFailWithError(_ errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Pop to root view controller when alert is dismissed
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    func didChangeLoadingState(isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

extension ImageNutritionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodListCell", for: indexPath) as? FoodListCell else {
//            fatalError("Unable to dequeue FoodListCell")
//        }
//        let food = viewModel.nutritionItems[indexPath.row]
//        cell.configureCell(with: food)
//        cell.onQuantityChanged = { [ weak self ] newQuantity in
//            self?.viewModel.updateQuantity(at: indexPath.row, quantity: newQuantity)
//        }
//        return cell
        
        guard let item = viewModel.item(at: indexPath) else {
            fatalError("Invalid indexPath")
        }
        
        switch item {
        case .food(let food):
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodListCell", for: indexPath) as! FoodListCell
            cell.configureCell(with: food)
            cell.onQuantityFieldDidBeginEditing = { [ weak self, weak cell ] in
                guard let self = self, let cell = cell else { return }
                self.activeCell = cell
            }
            cell.onQuantityFieldDidEndEditing = { [ weak self ] newQuantity in
                guard let self = self else { return }
                self.activeCell = nil
                self.viewModel.updateQuantity(at: indexPath.row, quantity: newQuantity)
            }
            cell.onQuantityFieldEdited = { [ weak self, weak cell ] newQuantity in
                guard let self = self, let cell = cell else { return }
                let scaledCalories = self.viewModel.getScaledCalories(at: indexPath.row, quantity: newQuantity)
                cell.updateCalories(scaledCalories)
            }
            return cell
            
        case .summary(let summary):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryCell", for: indexPath) as! SummaryCell
            cell.configure(with: summary.nutrients)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let foodIndex = indexPath.row - 1
        let selectedFood = viewModel.nutritionItems[foodIndex]
        let detailVM = FoodDetailViewModel(food: selectedFood)
        let detailVC = FoodDetailViewController(viewModel: detailVM, withAddButton: true)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NutritionSectionFooterView") as? NutritionSectionFooterView else {
//            fatalError("Unable to dequeue NutritionSectionFooterView")
//        }
//        
//        let nutrients = viewModel.getNutrientsForTable()
//        footerView.configureFooter(with: nutrients)
//        return footerView
//    }
}

extension ImageNutritionViewController: FoodDetailViewControllerDelegate {
    func foodDetailViewController(_ controller: FoodDetailViewController, didAddFood food: FoodNutrition) {
        // Pass this event up to the main FoodListViewController
        delegate?.imageNutritionViewController(self, didAddFoodFromDetail: food)

        navigationController?.popViewController(animated: true)
    }
}

