//
//  PDFUploadView.swift
//  Mentora
//
//  Created by Shamam Alkafri on 15/05/2025.
//


import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFUploadView: View {
    @ObservedObject var vm: PDFUploadViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showFilePicker = false
    @State private var agreedToTerms = false
    @State private var showPopup = false


    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: "#FEFAED").ignoresSafeArea()
            Image("bg").resizable().scaledToFill().ignoresSafeArea()

            // 🔙 Back button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.black)
                    .padding(.leading, 32)
                    .padding(.top, 32)
            }

            HStack(alignment: .center) {
                // 📥 Left section
                ZStack(alignment: .bottomLeading) {
                    VStack(alignment: .leading) {
                        Spacer()
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("★")
                                .font(.custom("IBMPlexMono-Bold", size: 34))
                                .foregroundColor(.black)
                                .padding(.top, -12)

                            Text("Upload Your file\nhere to get your\ngenerated questions")
                                .font(.custom("IBMPlexMono-Bold", size: 34))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.leading, 200)
                        .padding(.bottom, 40)

                        Spacer()
                    }

                    HStack {
                        WinkyGIFView()
                            .frame(width: 530, height: 530)
                            .padding(.leading, -60)
                            .padding(.bottom, -80)
                        Spacer()
                    }
                }
                .frame(width: 700)

                // 📤 Right section
                VStack(spacing: 32) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(width: 400, height: 250)

                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 390, height: 240)

                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black)
                                    .frame(width: 270, height: 70)

                                Button(action: {
                                    if agreedToTerms {
                                        showFilePicker = true
                                    }
                                }) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(hex: "#05D96A"))
                                        .frame(width: 260, height: 60)
                                        .overlay(
                                            Text("Upload File")
                                                .font(.custom("IBMPlexMono-Bold", size: 22))
                                                .foregroundColor(.black)
                                        )
                                }
                                .buttonStyle(.plain)
                                .disabled(!agreedToTerms)
                            }
                        }
                    }

                    HStack(spacing: 12) {
                        Button(action: {
                            agreedToTerms.toggle()
                        }) {
                            Image(systemName: agreedToTerms ? "checkmark.square" : "square")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }

                        Text("Terms And Conditions")
                            .font(.custom("IBMPlexMono-Regular", size: 18))
                            .foregroundColor(.black)
                    }
                }
                .padding(.trailing, 60)
            }

            //  Solo Game
            NavigationLink(
                destination: SoloGameSwipeView(vm: SoloGameViewModel(userId: vm.userId))
                    .environmentObject(authVM),
                isActive: $vm.navigateToGame
            ) {
                EmptyView()
            }
            .hidden()

            // Multiplayer Game
            NavigationLink(
                destination: MultiplayerLobbyView(
                    userId: vm.userId,
                    displayName: vm.displayName,
                    pinCode: vm.roomVM?.pinCode 
                )
                .environmentObject(authVM),
                isActive: $vm.navigateToMultiplayerLobby
            ) {
                EmptyView()
            }
            .hidden()

        }
        .navigationBarBackButtonHidden(true)
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            if case let .success(urls) = result, let pdfURL = urls.first {
                showPopup = true
                extractText(from: pdfURL)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        showPopup = false
                    }
                }
            }
        }
        .overlay(
            Group {
                if showPopup {
                    VStack(spacing: 12) {
                        Text(" PDF Uploaded Successfully!")
                            .font(.custom("IBMPlexMono-Bold", size: 24))
                            .foregroundColor(.green)

                        Text("Questions are being generated...\nThe game will start automatically.")
                            .font(.custom("IBMPlexMono-Regular", size: 18))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        ProgressView()
                    }
                    .padding()
                    .frame(width: 420)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .transition(.opacity)
                }
            }
        )

    }

    // MARK: - PDF Extraction
    func extractText(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        guard let data = try? Data(contentsOf: url),
              let pdfDocument = PDFDocument(data: data) else { return }

        var fullText = ""
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex),
               let text = page.string {
                fullText += text + "\n\n"
            }
        }

        vm.extractedText = cleanExtractedText(fullText)
        vm.sendToBackend()
    }

    func cleanExtractedText(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "\n+", with: "\n", options: .regularExpression)
            .replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}




#Preview {
    PDFUploadView(vm: PDFUploadViewModel(
        userId: "test",
        displayName: "Test",
        mode: "tf",
        roomVM: nil
    ))
    .environmentObject(AuthViewModel())
}
