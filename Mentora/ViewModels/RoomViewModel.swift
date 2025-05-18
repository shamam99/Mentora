//
//  RoomViewModel.swift
//  Mentora
//
//  Created by Shamam Alkafri on 15/05/2025.
//

import Foundation

class RoomManager {
    static let shared = RoomManager()

    var roomId: String?
    var pinCode: String?
}

class RoomViewModel: ObservableObject {
    @Published var roomId: String?
    @Published var pinCode: String?
    @Published var isSolo: Bool = true
    @Published var status: String?

    func createRoom(userId: String, mode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        APIManager.shared.createRoom(userId: userId, mode: mode) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let room):
                    self.roomId = room.roomId
                    self.pinCode = room.pinCode
                    self.isSolo = room.isSolo
                    self.status = room.status

                    // ✅ Save globally
                    RoomManager.shared.roomId = room.roomId
                    RoomManager.shared.pinCode = room.pinCode

                    completion(.success(()))
                case .failure(let error):
                    print("[RoomVM Error] \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
}

