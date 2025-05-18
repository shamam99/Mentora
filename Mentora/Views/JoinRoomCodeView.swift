//
//  JoinRoomCodeView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 15/05/2025.
//

import SwiftUI

struct JoinRoomCodeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var pinCode: String = ""
    @State private var navigateToLobby = false
    @State private var showError = false
    @State private var isLoading = false
    @FocusState private var isKeyboardFocused: Bool

    var body: some View {
        ZStack {
            Color(hex: "#FEFAED").ignoresSafeArea()

            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Tap outside to dismiss
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isKeyboardFocused = false
                }

            VStack(spacing: 32) {
                Text("Enter the game code to join")
                    .font(.custom("IBMPlexMono-Bold", size: 28))
                    .foregroundColor(.black)

                // PIN Code Display Boxes
                HStack(spacing: 16) {
                    ForEach(0..<6) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 60, height: 60)

                            if pinCode.count > index {
                                Text(String(pinCode[pinCode.index(pinCode.startIndex, offsetBy: index)]))
                                    .font(.custom("IBMPlexMono-Bold", size: 28))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .onTapGesture {
                    isKeyboardFocused = true
                }

                // Hidden Input Field
                TextField("", text: $pinCode)
                    .keyboardType(.numberPad)
                    .focused($isKeyboardFocused)
                    .frame(width: 0, height: 0)
                    .opacity(0.01)
                    .accentColor(.clear)
                    .onChange(of: pinCode) { newValue in
                        pinCode = String(newValue.prefix(6)).filter { $0.isNumber }
                    }

                // Join Button
                Button(action: {
                    joinRoom()
                }) {
                    Text("Join Room")
                        .font(.custom("IBMPlexMono-Bold", size: 22))
                        .foregroundColor(.white)
                        .frame(width: 220, height: 54)
                        .background(pinCode.count == 6 ? Color.green : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(pinCode.count != 6 || isLoading)

                if showError {
                    Text("Invalid or full room code.")
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                // Navigate to Lobby
                NavigationLink(
                    destination: MultiplayerLobbyView(
                        userId: authVM.user?._id ?? "",
                        displayName: authVM.user?.displayName ?? "",
                        pinCode: pinCode
                    ),
                    isActive: $navigateToLobby
                ) {
                    EmptyView()
                }
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isKeyboardFocused = true
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func joinRoom() {
        guard let user = authVM.user else {
            showError = true
            return
        }

        isLoading = true
        showError = false

        let socket = SocketService.shared.getSocket()
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

        socket.off("joinError")
        socket.off("multiplayerLobbyUpdate")

        socket.on("joinError") { _, _ in
            DispatchQueue.main.async {
                isLoading = false
                showError = true
            }
        }

        socket.on("multiplayerLobbyUpdate") { _, _ in
            DispatchQueue.main.async {
                isLoading = false
                navigateToLobby = true
            }
        }
    }
}


#Preview {
    JoinRoomCodeView()
        .environmentObject(AuthViewModel())
        .previewDevice("iPad Pro (11-inch)")
        .previewInterfaceOrientation(.landscapeLeft)
}
