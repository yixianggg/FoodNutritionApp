//
//  APIClient.swift
//  FoodNutritionApp
//
//  Created by Yi Xiang on 27/6/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

class APIClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
        
    func get<T: Decodable>(urlString: String, headers: [String: String] = [:], completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure((.invalidURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let task = session.dataTask(with: request) { data, response, error in
            // Error handling
            if let error = error {
                completion(.failure((.requestFailed(error))))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode,
                  let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch let decodeError {
                completion(.failure(.decodingFailed(decodeError)))
            }
        }
        
        task.resume()
    }
    
    func postMultipart<T: Decodable>(urlString: String, headers: [String: String] = [:], imageData: Data, imageName: String = "image.jpg", imageMimeType: String = "image/jpeg", completion: @escaping (Result<T, APIError>) -> Void) {
        
        // Create URL
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create URL request and set method to POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add headers
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // Generate boundary string for multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Build multipart body
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"media\"; filename=\"\(imageName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(imageMimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let task = session.dataTask(with: request) { data, response, error in
            // Error handling
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode,
                  let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch let decodeError {
                completion(.failure(.decodingFailed(decodeError)))
            }
        }
        
        task.resume()
    }
}
