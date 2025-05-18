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

    init() {}

    func initialize(userId: String, displayName: String, pinCode: String? = nil) {
        self.userId = userId
        self.displayName = displayName
        self.setupListeners()
        self.joinRoom(pinCode: pinCode)
    }

    // MARK: - Socket Setup
    private func setupListeners() {
        print("[MultiplayerLobbyVM] Setting up listeners")

        socket.off("multiplayerLobbyUpdate")
        socket.off("multiplayerGameStarted")

        socket.on("multiplayerLobbyUpdate") { [weak self] data, _ in
            guard let self = self,
                  let dict = data.first as? [String: Any],
                  let pin = dict["pinCode"] as? String,
                  let names = dict["players"] as? [String],
                  let hostId = dict["hostId"] as? String else {
                print(" Invalid lobby update data")
                return
            }

            DispatchQueue.main.async {
                self.pinCode = pin
                self.players = names
                self.isHost = (hostId == self.userId)
                print("Lobby Update → Players: \(names), isHost: \(self.isHost)")
            }
        }

        socket.on("multiplayerGameStarted") { [weak self] _, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                print("Received multiplayerGameStarted. Navigating to game.")
                self.gameVM = MultiplayerGameViewModel(userId: self.userId)
                self.navigateToGame = true
            }
        }
    }

    // MARK: - Join Room
    private func joinRoom(pinCode: String?) {
        let payload: [String: String] = {
            var dict: [String: String] = [
                "userId": userId,
                "displayName": displayName
            ]
            if let pin = pinCode {
                dict["pinCode"] = pin
            }
            return dict
        }()

        if socket.status != .connected {
            socket.once("connect") { [weak self] _, _ in
                print("[Socket] Connected. Emitting joinMultiplayerRoom: \(payload)")
                self?.socket.emit("joinMultiplayerRoom", payload)
            }
            print("[Socket] Connecting socket...")
            socket.connect()
        } else {
            print("[Socket] Already connected. Emitting joinMultiplayerRoom: \(payload)")
            socket.emit("joinMultiplayerRoom", payload)
        }
    }

    // MARK: - Host Starts Game
    func startGame() {
        guard let roomId = RoomManager.shared.roomId else {
            print("[LobbyVM] Missing roomId for starting game")
            return
        }

        let payload: [String: String] = [
            "userId": userId,
            "roomId": roomId
        ]

        if socket.status != .connected {
            socket.once("connect") { [weak self] _, _ in
                print("[LobbyVM] Connected. Emitting startMultiplayerGame: \(payload)")
                self?.socket.emit("startMultiplayerGame", payload)
            }
            print("[LobbyVM] Reconnecting socket before emitting start game...")
            socket.connect()
        } else {
            print("[LobbyVM] Emitting startMultiplayerGame: \(payload)")
            socket.emit("startMultiplayerGame", payload)
        }
    }
}
