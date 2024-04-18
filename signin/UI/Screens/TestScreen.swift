import SwiftUI
import Combine

struct TestView: View {
    @Environment(\.injected) private var container: DIContainer

    @State private var userData: String = ""
    private var userBinding: Binding<String> {
        $userData.dispatched(to: container.appState, \.userData.givenName)
    }

  var body: some View {
    ZStack() {
      Rectangle()
        .foregroundColor(.clear)
        .frame(width: 369, height: 710)
        .background(.white)
        .cornerRadius(8)
        .offset(x: 0, y: 55)
      HStack(spacing: 8) {
        HStack(spacing: 0) {

        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0.40))
        .frame(width: 20, height: 20)
        Button(action: {
            Task {
                do {
                    container.interactors.authService!.signIn()
                }
            }
        }) {
            HStack {
                Spacer()
                Text("Googleでログイン")
                    .font(Font.custom("Hiragino Kaku Gothic Pro", size: 16).weight(.semibold))
                    .foregroundColor(.black)
                Spacer()
            }
            .onReceive(userDataUpdate) {userData = $0}
        }
      }
      .frame(width: 329, height: 60)
      .background(Color(red: 0.88, green: 0.88, blue: 0.88))
      .cornerRadius(8)
      .offset(x: 0, y: -38)
      HStack(spacing: 8) {
        HStack(spacing: 0) {

        }
        .padding(EdgeInsets(top: 0, leading: 1.88, bottom: 0, trailing: 1.87))
        .frame(width: 20, height: 20)

          Button(action: {
              print("Login by Apple")
          }) {
              HStack {
                  Spacer()
                  Text("Appleでログイン")
                      .font(Font.custom("Hiragino Kaku Gothic Pro", size: 16).weight(.semibold))
                      .foregroundColor(.black)
                  Spacer()
              }
          }
      }
      .frame(width: 329, height: 60)
      .background(Color(red: 0.88, green: 0.88, blue: 0.88))
      .cornerRadius(8)
      .offset(x: 0, y: 32)


        Button(action: {
            print("Move to register")
        }) {
            HStack {
                Text("新規アカウント作成こちら")
                  .font(
                    Font.custom("Hiragino Kaku Gothic Pro", size: 15).weight(.semibold)
                  )
                  .foregroundColor(.black)
            }
        }.offset(x: -0.50, y: 145.50)


      Text("kijiita")
        .font(
          Font.custom("Hiragino Kaku Gothic Pro", size: 20).weight(.semibold)
        )
        .foregroundColor(.black)
        .offset(x: 0, y: -183)

      Rectangle()
        .foregroundColor(.clear)
        .frame(width: 329, height: 1)
        .background(Color(red: 0.87, green: 0.87, blue: 0.87))
        .offset(x: 0, y: 97.50)

      HStack(spacing: 0) {
        Text("ログイン")
          .font(
            Font.custom("Hiragino Kaku Gothic Pro", size: 16).weight(.semibold)
          )
          .foregroundColor(.black)
      }
      .padding(EdgeInsets(top: 68, leading: 0, bottom: 18, trailing: 0))
      .frame(width: 393, height: 110)
      .background(Color(red: 0.89, green: 0.91, blue: 0.93))
      .overlay(
        Rectangle()
          .inset(by: 0.50)
          .stroke(Color(red: 0.80, green: 0.80, blue: 0.80), lineWidth: 0.50)
      )
      .offset(x: 0, y: -371)
    }
    .frame(width: 393, height: 852)
    .background(Color(red: 0.89, green: 0.91, blue: 0.93));
  }
}

extension TestView {
    fileprivate var userDataUpdate: AnyPublisher<String, Never> {
        container.appState.updates(for: \.userData.givenName)
    }
}

struct TestView_Previews: PreviewProvider {
  static var previews: some View {
      TestView()
  }
}
