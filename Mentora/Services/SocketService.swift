//
//  SocketService.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//


import Foundation
import SocketIO

final class SocketService {
    static let shared = SocketService()

    private var manager: SocketManager
    private var socket: SocketIOClient

    private init() {
        self.manager = SocketManager(
            socketURL: URL(string: "http://192.168.8.153:3001")!,
            config: [
                .log(true),
                .compress,
                .reconnects(true),
                .forceNew(true),
                .connectParams(["platform": "iOS"])
            ]
        )

        self.socket = manager.defaultSocket
    }

    /// Public accessor
    func getSocket() -> SocketIOClient {
        return socket
    }

    /// Manual connect trigger (optional fallback)
    func ensureConnected() {
        if socket.status != .connected && socket.status != .connecting {
            print("[SocketService] Manually connecting...")
            socket.connect()
        } else {
            print("[SocketService] Already connected or connecting")
        }
    }

    /// Optional: Disconnect safely
    func disconnect() {
        socket.disconnect()
        print("[SocketService] Disconnected")
    }
}
