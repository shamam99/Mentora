//
//  APIService.swift
//  PDFExtract
//
//  Created by Shamam Alkafri on 14/05/2025.
//

import Foundation

class APIService {
    static let shared = APIService()
    private init() {}

    func generateQuestions(from text: String, mode: String = "both", completion: @escaping (Result<[Question], Error>) -> Void) {
        guard let url = URL(string: "http://172.20.10.14:8000/api/question/generate") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "text": text,
            "mode": mode
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        // Custom URLSession with timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 180
        config.timeoutIntervalForResource = 180
        let session = URLSession(configuration: config)

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0)))
                return
            }
            

            do {
                
                let decoded = try JSONDecoder().decode([String: [Question]].self, from: data)
                if let questions = decoded["questions"] {
                    completion(.success(questions))
                } else {
                    completion(.failure(NSError(domain: "Invalid response structure", code: 0)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}
