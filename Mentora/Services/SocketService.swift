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
        self.manager = SocketManager(socketURL: URL(string: "http://172.20.10.14:3001")!, config: [.log(true), .compress])
        self.socket = manager.defaultSocket
        socket.connect()
    }

    func getSocket() -> SocketIOClient {
        return socket
    }
}
