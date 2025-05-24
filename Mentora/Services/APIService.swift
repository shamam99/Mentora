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

    private let openAIKey = "Api KEY"

    func generateQuestions(from text: String, mode: String = "both", completion: @escaping (Result<[Question], Error>) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 0)))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")

        // Prompts for both modes
        let tfPrompt = """
        You are a precise and intelligent quiz assistant.

        You will receive academic content. Your task is first to read everything very very well each line if there any broken try and fix it first then make a full read for the content u have to extract clear, meaningful, and factually correct True/False statements from the content suitable for a game please each time u will recive u will try and generate something professional please and correct don't make it too long or too short try to see the important things the user must practice on it please each time.

        Format each item like this:
        {
          "type": "true_false",
          "statement": "IPsec provides encryption and authentication.",
          "is_true": true
        }

        - Only output a JSON array.
        - Do NOT add any markdown, explanation, or text before/after the JSON.
        """

        let mcqPrompt = """
        You are a professional question generator for a multiplayer academic quiz app.

        You will receive educational content. Your task is first to read everything very very well each line if there any broken try and fix it first then make a full read for the content u have to extract clear, meaningful, and factually correct multiple-choice questions from the content suitable for a game please each time u will recive u will try and generate something professional please and correct don't make it too long or too short try to see the important things the user must practice on it please each time.

        Each item must follow this format:
        {
          "type": "multiple_choice",
          "question": "Which mode in IPsec encrypts the entire IP packet?",
          "choices": [
            { "answer": "Tunnel Mode", "correct": true },
            { "answer": "Transport Mode", "correct": false },
            { "answer": "Encryption Mode", "correct": false },
            { "answer": "Authentication Mode", "correct": false }
          ],
          "correct_answer": "Tunnel Mode"
        }

        - Only return a JSON array.
        - Do NOT include any text or explanation outside the JSON.
        """

        let selectedPrompt = (mode == "mcq") ? mcqPrompt : tfPrompt

        let payload: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": selectedPrompt],
                ["role": "user", "content": text.prefix(7000)]  // Trim input to be token-safe
            ],
            "temperature": 0.7
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            return completion(.failure(error))
        }

        print("📤 Sending request to OpenAI...")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "None")")

        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return completion(.failure(error))
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📥 OpenAI status code:", httpResponse.statusCode)
            }

            guard let data = data else {
                print("❌ No data received.")
                return completion(.failure(NSError(domain: "No data", code: 0)))
            }

            if let responseText = String(data: data, encoding: .utf8) {
                print("🧾 Raw response:\n\(responseText)")
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let message = choices.first?["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    print("⚠️ Invalid response structure.")
                    return completion(.failure(NSError(domain: "Invalid format", code: 0)))
                }

                let cleanContent = content
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let decoded = try JSONDecoder().decode([Question].self, from: Data(cleanContent.utf8))
                completion(.success(decoded))

                print("✅ Parsed \(decoded.count) questions.")
            } catch {
                print("❌ JSON decode error:", error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }
}
