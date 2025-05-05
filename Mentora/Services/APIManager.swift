import Foundation

class APIManager {
    static let shared = APIManager()
    private let baseURL = "http://172.20.10.14:3001"

    func loginWithGameCenter(payload: [String: String], completion: @escaping (Result<(User, String), Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/apple-gamecenter-login") else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 1001)))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(NSError(domain: "Invalid response", code: 1003)))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "No data", code: 1002)))
            }

            // Only try to decode if statusCode is 200
            if httpResponse.statusCode == 200 {
                do {
                    print("RAW RESPONSE: \(String(data: data, encoding: .utf8) ?? "Invalid UTF8")")
                    let decoded = try JSONDecoder().decode(AuthResponse.self, from: data)
                    completion(.success((decoded.data.user, decoded.data.token)))
                } catch {
                    completion(.failure(error))
                }
            } else {
                // Return readable backend error if login failed
                let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
                return completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    func fetchUserProfile(using token: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/user/me") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1001)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "No data", code: 1002)))
            }

            do {
                let decodedUser = try JSONDecoder().decode(User.self, from: data)
                completion(.success(decodedUser))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
