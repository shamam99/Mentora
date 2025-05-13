//
//  MultiplayerLobbyViewModel.swift
//  Mentora
//
//  Created by Shamam Alkafri on 07/05/2025.
//

import Foundation
import SocketIO

final class MultiplayerLobbyViewModel: ObservableObject {
    @Published var pinCode: String = ""
    @Published var players: [String] = []
    @Published var isHost: Bool = false
    @Published var navigateToGame: Bool = false
    @Published var gameVM: MultiplayerGameViewModel?

    private var userId: String = ""
    private var displayName: String = ""
    private let socket = SocketService.shared.getSocket()

    var canStartGame: Bool {
        return isHost && players.count >= 2
    }

    init() {
        setupListeners()
    }

    func joinRoom(userId: String, displayName: String, pinCode: String? = nil) {
        self.userId = userId
        self.displayName = displayName

        var payload: [String: String] = [
            "userId": userId,
            "displayName": displayName
        ]
        if let pin = pinCode {
            payload["pinCode"] = pin
        }

        if socket.status != .connected {
            socket.once("connect") { [weak self] _, _ in
                self?.socket.emit("joinMultiplayerRoom", payload)
            }
            socket.connect()
        } else {
            socket.emit("joinMultiplayerRoom", payload)
        }
    }

    func startGame() {
        socket.emit("startMultiplayerGame", ["userId": userId])
    }

    private func setupListeners() {
        socket.off("multiplayerLobbyUpdate")
        socket.off("multiplayerGameStarted")

        socket.on("multiplayerLobbyUpdate") { [weak self] data, _ in
            guard let self = self,
                  let dict = data.first as? [String: Any],
                  let pin = dict["pinCode"] as? String,
                  let names = dict["players"] as? [String],
                  let hostId = dict["hostId"] as? String else { return }

            DispatchQueue.main.async {
                self.pinCode = pin
                self.players = names
                self.isHost = (hostId == self.userId)
                print("Lobby Update → Players: \(names)")
            }
        }

        socket.on("multiplayerGameStarted") { [weak self] _, _ in
            guard let self = self else { return }

            DispatchQueue.main.async {
                print("Game started. Navigating...")
                self.gameVM = MultiplayerGameViewModel(userId: self.userId)
                self.navigateToGame = true
            }
        }
    }
}
