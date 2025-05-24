//
//  ChooseModeView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 15/05/2025.
//

import SwiftUI

struct ChooseModeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var pressedButton: String? = nil
    @Environment(\.presentationMode) var presentationMode
    @StateObject var roomVM = RoomViewModel()
    @State private var navigateToPDFUploadSolo = false
    @State private var navigateToPDFUploadMulti = false



    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: "#FEFAED").ignoresSafeArea()
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Back Arrow (absolute top-left)
            BackExitButton(icon: "chevron.left", topPadding: 30, leftPadding: 62, sound: "3") {
                presentationMode.wrappedValue.dismiss()
            }




            VStack {
                Spacer().frame(height: 300)

                Text("How would you like to play today ?")
                    .font(.custom("IBMPlexMono-Bold", size: 28))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 50)

                HStack(spacing: 60) {
                    // Solo Game
                    MentoraShadowButton(
                        label: "Solo game",
                        defaultColor: "#C09DDF",
                        pressedColor: "#945DC5",
                        width: 310,
                        height: 160,
                        fontSize: 22,
                        cornerRadius: 10,
                        isPressed: pressedButton == "solo",
                        action: {
                            pressedButton = "solo"
                            roomVM.createRoom(userId: authVM.user?._id ?? "", mode: "solo") { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        pressedButton = nil
                                        navigateToPDFUploadSolo = true
                                    case .failure(let error):
                                        print("Room creation failed: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    )

                    // Multiplayer Game
                    MentoraShadowButton(
                        label: "Multiplayer game",
                        defaultColor: "#C09DDF",
                        pressedColor: "#945DC5",
                        width: 310,
                        height: 160,
                        fontSize: 22,
                        cornerRadius: 10,
                        isPressed: pressedButton == "multi",
                        action: {
                            pressedButton = "multi"
                            roomVM.createRoom(userId: authVM.user?._id ?? "", mode: "multiplayer") { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        pressedButton = nil
                                        navigateToPDFUploadMulti = true
                                    case .failure(let error):
                                        print("Room creation failed: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    )
                }
                .frame(maxWidth: .infinity)


                Spacer()
            }
            .frame(maxWidth: .infinity)
            NavigationLink(
                destination: PDFUploadView(
                    vm: PDFUploadViewModel(
                        userId: authVM.user?._id ?? "",
                        displayName: authVM.user?.displayName ?? "",
                        mode: "tf", // solo mode
                        roomVM: roomVM
                    )
                ).environmentObject(authVM),
                isActive: $navigateToPDFUploadSolo,
                label: { EmptyView() }
            ).hidden()
            
            NavigationLink(
                destination: PDFUploadView(
                    vm: PDFUploadViewModel(
                        userId: authVM.user?._id ?? "",
                        displayName: authVM.user?.displayName ?? "",
                        mode: "mcq", // multiplayer mode
                        roomVM: roomVM
                    )
                ).environmentObject(authVM),
                isActive: $navigateToPDFUploadMulti,
                label: { EmptyView() }
            ).hidden()

        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Navigation logic
    @ViewBuilder
    func navigateToPDFUpload(mode: String) -> some View {
        NavigationLink(
            destination: PDFUploadView(
                vm: PDFUploadViewModel(
                    userId: authVM.user?._id ?? "",
                    displayName: authVM.user?.displayName ?? "",
                    mode: mode == "solo" ? "tf" : "mcq",
                    roomVM: roomVM
                )
            )
            .environmentObject(authVM),
            isActive: .constant(true),
            label: { EmptyView() }
        ).hidden()
    }

}


#Preview {
    NavigationStack {
        ChooseModeView()
            .environmentObject(AuthViewModel())
    }
    .previewDevice("iPad Pro (11-inch)")
    .previewInterfaceOrientation(.landscapeLeft)
}
