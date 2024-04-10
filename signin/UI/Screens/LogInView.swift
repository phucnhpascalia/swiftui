import SwiftUI
import Combine

struct LogInView: View {
    @Environment(\.injected) private var container: DIContainer

    @State private var userData: String = ""
    private var userBinding: Binding<String> {
        $userData.dispatched(to: container.appState, \.userData.givenName)
    }

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    VStack {
                        Spacer()
                        VStack {
                            Text("Login")
                                .font(.largeTitle)
                                .bold()
                                .padding(.bottom,30)

                                SocalLoginButton(image: Image("google"), text: Text("Continue in with Google")) {
                                    Task {
                                        do {
                                            container.interactors.authService!.signIn()
                                        }
                                    }
                                }
                        }
                        .onReceive(nameUpdate) {userData = $0}

                        Spacer()
                        Spacer()
                    }
                }.padding()
            }
            .accentColor(Color.blue)
        }
    }
}

extension LogInView {
    fileprivate var nameUpdate: AnyPublisher<String, Never> {
        container.appState.updates(for: \.userData.givenName)
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}

struct SocalLoginButton: View {
    var image : Image
    var text : Text
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                image
                    .padding(.horizontal)
                Spacer()
                text
                    .font(.title3)
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(50)
        .shadow(color: Color.black.opacity(0.2), radius: 30, x: 2, y: 2)
    }
}
