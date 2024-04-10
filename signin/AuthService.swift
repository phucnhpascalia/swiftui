import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
final class AuthService: ObservableObject {
    let appState: Store<AppState>
    var errorMessage: String = ""

    init(appState: Store<AppState>) {
        self.appState = appState
        check()
    }

    func getUserStatus() {
        if GIDSignIn.sharedInstance.currentUser != nil {
            let user = GIDSignIn.sharedInstance.currentUser
            guard let user = user else { return }
            let givenName = user.profile?.givenName

            self.appState.bulkUpdate { state in
                state.userData.givenName = givenName ?? ""
                state.userData.userEmail = user.profile!.email
                state.userData.profilePicUrl = user.profile!.imageURL(withDimension: 100)!.absoluteString
                state.userData.isLoggedIn = true
            }
        } else {
            self.appState.bulkUpdate { state in
                state.userData.isLoggedIn = false
                state.userData.givenName = "Not Logged In"
            }
        }
    }

    func check() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            self.getUserStatus()
        }
    }

    func gertRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }

    func signIn() {
        GIDSignIn.sharedInstance.signIn(withPresenting: gertRootViewController()) { signInResult, error in
            guard let result = signInResult else {
                // Inspect error
                print("Error occured in signIn()")
                return
            }
            print("Signing in ...")
            print(result.user.profile?.givenName ?? "")
            self.getUserStatus()
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.getUserStatus()
    }
}
