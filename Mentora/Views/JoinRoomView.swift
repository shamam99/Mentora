//
//  JoinRoomView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 05/05/2025.
//

import SwiftUI
import SocketIO

struct JoinRoomView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var pinCode: String = ""
    @State private var showLobby = false
    @State private var showError = false
    @State private var isLoading = false

    private let socket = SocketService.shared.getSocket()

    var body: some View {
        VStack(spacing: 24) {
            Text("Enter Room PIN")
                .font(.title2)
                .bold()

            TextField("6-digit PIN", text: $pinCode)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .frame(width: 200)

            if isLoading {
                ProgressView("Joining...")
                    .progressViewStyle(CircularProgressViewStyle())
            }

            Button(action: {
                joinRoom()
            }) {
                Text("Join Room")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(pinCode.count == 6 && !isLoading ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(pinCode.count != 6 || isLoading || authVM.user == nil)

            if showError {
                Text("Failed to join room. Check PIN or connection.")
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            NavigationLink(
                destination: MultiplayerLobbyView(
                    userId: authVM.user?._id ?? "",
                    displayName: authVM.user?.displayName ?? "",
                    pinCode: pinCode
                ),
                isActive: $showLobby
            ) {
                EmptyView()
            }
        }
        .padding()
        .navigationTitle("Join Room")
        .onAppear {
            setupSocketListeners()
        }
    }

    private func joinRoom() {
        guard let user = authVM.user else {
            showError = true
            return
        }

        isLoading = true
        showError = false

        let payload: [String: String] = [
            "userId": user._id,
            "displayName": user.displayName,
            "pinCode": pinCode
        ]

        if socket.status != .connected {
            socket.once("connect") { _, _ in
                socket.emit("joinMultiplayerRoom", payload)
            }
            socket.connect()
        } else {
            socket.emit("joinMultiplayerRoom", payload)
        }
    }

    private func setupSocketListeners() {
        socket.off("joinError") // Prevent multiple handlers
        socket.off("multiplayerLobbyUpdate")

        socket.on("joinError") { data, _ in
            DispatchQueue.main.async {
                isLoading = false
                showError = true
            }
        }

        socket.on("multiplayerLobbyUpdate") { data, _ in
            DispatchQueue.main.async {
                isLoading = false
                showLobby = true
            }
        }
    }
}
