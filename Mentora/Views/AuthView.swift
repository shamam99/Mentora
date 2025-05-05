import SwiftUI

struct AuthView: View {
    @StateObject var authVM = AuthViewModel()
    @EnvironmentObject var gameCenterManager: GameCenterManager
    @State private var showSplash = true

    var body: some View {
        NavigationStack {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            showSplash = false

                            //  Check Game Center
                            if gameCenterManager.isAuthenticated {
                                authVM.login()
                            } else {
                                authVM.error = "Game Center login failed."
                            }
                        }
                    }
            } else {
                if let _ = authVM.user {
                    HomeView()
                } else if let error = authVM.error {
                    VStack(spacing: 24) {
                        Spacer()
                        Text("Login Failed")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)

                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                    .padding()
                    .background(Color.black.ignoresSafeArea())
                } else {
                    SplashView() 
                }
            }
        }
    }
}
