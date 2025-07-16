//
//  FoodListViewController.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 27/6/25.
//

import Foundation
import UIKit

class FoodListViewController: UIViewController {
    
    private let viewModel: FoodListViewModel
    
    private weak var activeCell: UITableViewCell?
    
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(viewModel: FoodListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFoodListUI()
        setUpFoodListConstraints()
        setUpFoodListDelegates()
        setUpNavigationBar()
        viewModel.load()
    }
    
    private func setUpFoodListUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        tableView.register(FoodListCell.self, forCellReuseIdentifier: "FoodListCell")
        tableView.register(SummaryCell.self, forCellReuseIdentifier: "SummaryCell")
        // tableView.register(NutritionSectionFooterView.self, forHeaderFooterViewReuseIdentifier: "NutritionSectionFooterView")
        
        activityIndicator.hidesWhenStopped = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setUpFoodListConstraints() {
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
    
    private func setUpFoodListDelegates() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setUpNavigationBar() {
        title = "Nutrition Tracker"
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFoodItemTapped))
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonTapped))
        
        navigationItem.rightBarButtonItems = [addButton, cameraButton]
    }
    
    @objc private func addFoodItemTapped() {
        let addFoodVC = AddFoodViewController()
        addFoodVC.delegate = self
        let nav = UINavigationController(rootViewController: addFoodVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(nav, animated: true)
    }
    
    @objc private func cameraButtonTapped() {
        let uploadVC = ImageUploadViewController()
        uploadVC.delegate = self
        let nav = UINavigationController(rootViewController: uploadVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(nav, animated: true)
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

extension FoodListViewController: FoodListViewModelDelegate {
    func didUpdateFoods() {
        tableView.reloadData()
    }
    
    func didFailWithError(_ errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
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

extension FoodListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodListCell", for: indexPath) as? FoodListCell else {
//            fatalError("Unable to dequeue FoodListCell")
//        }
//        if let food = viewModel.food(at: indexPath) {
//            cell.configureCell(with: food)
//            cell.onQuantityChanged = { [ weak self ] newQuantity in
//                self?.viewModel.updateQuantity(at: indexPath, quantity: newQuantity)
//            }
//        }
//        
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
                self.viewModel.updateQuantity(at: indexPath, quantity: newQuantity)
            }
            cell.onQuantityFieldEdited = { [ weak self, weak cell ] newQuantity in
                guard let self = self, let cell = cell else { return }
                let scaledCalories = self.viewModel.getScaledCalories(at: indexPath, quantity: newQuantity)
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
        if let selectedFood = viewModel.food(at: indexPath) {
            let detailVM = FoodDetailViewModel(food: selectedFood)
            let detailVC = FoodDetailViewController(viewModel: detailVM)
            navigationController?.pushViewController(detailVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [ weak self ] (_, _, completionHandler) in
            self?.viewModel.deleteFood(at: indexPath)
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForSection(section)
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NutritionSectionFooterView") as? NutritionSectionFooterView else {
//            fatalError("Unable to dequeue NutritionSectionFooterView")
//        }
//        
//        let nutrients = viewModel.getNutrientsForSection(for: section)
//        footerView.configureFooter(with: nutrients)
//        return footerView
//    }
}

extension FoodListViewController: AddFoodViewControllerDelegate {
    func addFoodViewController(_ controller: AddFoodViewController, didAddFood foodName: String, date: Date) {
        controller.dismiss(animated: true)
        
        viewModel.searchFoods(query: foodName, for: date)
    }
    
    func addFoodViewControllerDidCancel(_ controller: AddFoodViewController) {
        controller.dismiss(animated: true)
    }
}

extension FoodListViewController: ImageUploadViewControllerDelegate {
    func imageUploadViewController(_ controller: ImageUploadViewController, didScanImage imageData: Data) {
        controller.dismiss(animated: true)
        
        // Initialize the ImageNutritionViewModel and ViewController
        let imageNutritionVM = ImageNutritionViewModel(service: viewModel.nutritionService)
        let resultsVC = ImageNutritionViewController(viewModel: imageNutritionVM)
        resultsVC.delegate = self
        
        // Push the results view controller
        navigationController?.pushViewController(resultsVC, animated: true)
        
        // Start fetching nutrition data from the image
        imageNutritionVM.fetchNutritionFromImage(imageData)
    }
    
    func imageUploadControllerDidCancel(_ controller: ImageUploadViewController) {
        controller.dismiss(animated: true)
    }
}

extension FoodListViewController: ImageNutritionViewControllerDelegate {
    func imageNutritionViewController(_ controller: ImageNutritionViewController, didAddFoodFromDetail food: FoodNutrition) {
        let today = Date()
        viewModel.addFood(food, for: today)
    }
}
