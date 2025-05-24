//
//  JoinRoomCodeView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 15/05/2025.
//

import SwiftUI

struct JoinRoomCodeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

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

            VStack(spacing: 30) {
                // Top Back Button
                HStack {
                    Button(action: {
                        SoundPlayer.shared.playSound(named: "3")
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 60)
                    Spacer()
                }
                .padding(.top, 50)

                Spacer()

                // Main Content Centered
                VStack(spacing: 42) {
                    Text("Enter the game code to join")
                        .font(.custom("IBMPlexMono-Bold", size: 32))
                        .foregroundColor(.black)

                    // PIN Code Boxes
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
                            .onTapGesture {
                                isKeyboardFocused = true 
                            }

                        }
                    }
                    .onTapGesture {
                        isKeyboardFocused = true
                    }

                    // Join Button
                    Button(action: {
                        SoundPlayer.shared.playSound(named: "1")
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

                    // Navigation
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

                Spacer()
            }
            .padding(.horizontal)

            // Hidden TextField Overlay (always positioned but invisible)
            TextField("", text: $pinCode)
                .keyboardType(.numberPad)
                .focused($isKeyboardFocused)
                .opacity(0.001)
                .frame(width: 1, height: 1)
                .onChange(of: pinCode) { newValue in
                    pinCode = String(newValue.prefix(6)).filter { $0.isNumber }
                }
        }
        .onTapGesture {
            isKeyboardFocused = false
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
