//
//  SceneDelegate.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 27/6/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create new UIWindow
        let window = UIWindow(windowScene: windowScene)
        
        // Initialise services
        let apiKey = "3DTdKhgOt7DbGLiGRsyu8A==0z7zG2yFXkBhc9sJ"
        let nutritionService = FoodService(apiKey: apiKey)
        let storageService = FoodStorageService()
        
        // Create ViewModel with service
        let viewModel = FoodListViewModel(foodService: nutritionService, storageService: storageService)
        
        // Create root view controller with the ViewModel
        let foodListVC = FoodListViewController(viewModel: viewModel)
        
        // Embed in a navigation controller
        let navigationController = UINavigationController(rootViewController: foodListVC)
        
        // Set the rootViewController and make window visible
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
        
        // API call (for testing)
//        let api = FoodService(apiKey: "3DTdKhgOt7DbGLiGRsyu8A==0z7zG2yFXkBhc9sJ")
//        api.fetchFoods(for: "100g of guava with 50g of watermelon") { result in
//            switch result {
//            case .success(let response):
//                print("Foods: \(response.items)")
//            case .failure(let error):
//                print("API error: \(error)")
//            }
//        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

