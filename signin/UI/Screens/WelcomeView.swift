import SwiftUI

struct WelcomeView: View {
    @Environment(\.injected) private var container: DIContainer

    var body: some View {
        NavigationView {
            ZStack {
                Color("BgColor").edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Image("onboard")
                    Spacer()
                    PrimaryButton(title: "Get Started")

                    NavigationLink {
                        TestView().inject(container)
                    } label: {
                        Text("Login")
                            .font(.title3)
                            .bold()
                            .foregroundColor(Color.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(50)
                            .shadow(color: Color.black.opacity(0.2), radius: 30, x: 2, y: 2)
                            .padding(.vertical)
                    }
                }
                .padding()
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView().inject(.preview)
    }
}

struct PrimaryButton: View {
    var title : String
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(50)
    }
}
