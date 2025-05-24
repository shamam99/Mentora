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
    @State private var showTermsPopup = false
    @State private var showExtendedWaitingMessage = false
    @State private var showLongWaitMessage = false





    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: "#FEFAED").ignoresSafeArea()
            Image("bg").resizable().scaledToFill().ignoresSafeArea()

            //  Back button
            BackExitButton(icon: "chevron.left", topPadding: 30, leftPadding: 62, sound: "3") {
                presentationMode.wrappedValue.dismiss()
            }


            .padding(.leading, 62)

            HStack(alignment: .center) {
                //  Left section
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

                //  Right section
                VStack(spacing: 42) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(width: 500, height: 350)

                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 490, height: 340)

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

                        Button(action: {
                            withAnimation {
                                showTermsPopup = true
                            }
                        }) {
                            Text("Terms And Conditions")
                                .underline()
                                .font(.custom("IBMPlexMono-Regular", size: 18))
                                .foregroundColor(.black)
                        }
                        .buttonStyle(.plain)
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
                SoundPlayer.shared.playSound(named: "2")
                if case let .success(urls) = result, let pdfURL = urls.first {
                    SoundPlayer.shared.playSound(named: "2")
                    showPopup = true
                    showExtendedWaitingMessage = false
                    showLongWaitMessage = false
                    extractText(from: pdfURL)

                    // Show extended message after 10 sec
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        withAnimation {
                            showExtendedWaitingMessage = true
                        }
                    }

                    // Show long-wait message after 60 sec
                    DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                        if showPopup {
                            withAnimation {
                                showLongWaitMessage = true
                            }
                        }
                    }
                }

            }
        }
        .overlay(
            Group {
                if showPopup {
                    ZStack {
                        Color.black.opacity(0.35)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            if showLongWaitMessage {
                                Text("Still cooking your questions 🍳")
                                    .font(.custom("IBMPlexMono-Bold", size: 22))
                                    .foregroundColor(Color(hex: "#05D96A"))

                                Text("This PDF must be legendary! Give us a bit more time to finish the masterpiece.")
                                    .font(.custom("IBMPlexMono-Regular", size: 17))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            } else if showExtendedWaitingMessage {
                                Text("Get your snacks ready 🍿")
                                    .font(.custom("IBMPlexMono-Bold", size: 22))
                                    .foregroundColor(Color(hex: "#05D96A"))

                                Text("This battle of knowledge is about to begin. We’re preparing your finest quiz weapons!")
                                    .font(.custom("IBMPlexMono-Regular", size: 17))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            } else {
                                Text("📄 PDF Uploaded!")
                                    .font(.custom("IBMPlexMono-Bold", size: 24))
                                    .foregroundColor(Color(hex: "#05D96A"))

                                Text("Summoning questions from the depths of your file...\nGet ready to conquer!")
                                    .font(.custom("IBMPlexMono-Regular", size: 17))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            ProgressView()
                        }
                        .padding()
                        .frame(width: 460, height: 200)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .transition(.opacity)
                    }
                }
                //  Terms and Conditions Popup
                if showTermsPopup {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    showTermsPopup = false
                                }
                            }

                        VStack(spacing: 16) {
                            Text("Terms and Conditions")
                                .font(.custom("IBMPlexMono-Bold", size: 22))
                                .foregroundColor(.black)

                            ScrollView {
                                Text("""
        By uploading a PDF, you confirm that:
        - You have the right to use and share the content.
        - The file does not contain any copyrighted or sensitive materials.
        - The application may analyze the content to generate educational questions.
        - No data will be permanently stored unless explicitly agreed.

        Use of this tool is for learning and fair use only.
        """)
                                    .font(.custom("IBMPlexMono-Regular", size: 16))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 10)
                            }
                            .frame(height: 180)

                            Button(action: {
                                withAnimation {
                                    showTermsPopup = false
                                }
                            }) {
                                Text("Close")
                                    .font(.custom("IBMPlexMono-Bold", size: 18))
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "#05D96A"))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .frame(width: 600, height: 400)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 12)
                    }
                    .transition(.opacity)
                }
            }
        )
        .onChange(of: vm.navigateToGame) { newValue in
            if newValue {
                withAnimation {
                    showPopup = false
                }
            }
        }
        .onChange(of: vm.navigateToMultiplayerLobby) { newValue in
            if newValue {
                withAnimation {
                    showPopup = false
                }
            }
        }
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
