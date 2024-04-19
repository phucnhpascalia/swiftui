import Combine
import Lexical
import SwiftUI
import WebKit

enum PopupEmbedType {
    case instagramLink
    case twitterLink
    case youtubeLink
}

class MapViewModel: ObservableObject {
    @Published var didPressButton = false
    @Published var popupType: PopupEmbedType? = nil
}

extension UIScreen {
    static let screenSize = UIScreen.main.bounds.size
}


struct HomeView: View {
    @ObservedObject var viewModel = MapViewModel()

    @StateObject var store = LexicalStore()
    @Environment(\.injected) private var container: DIContainer
    @State private var searchText = ""
    @State private var products: [ProductModel] = []
    @State private var cartCount = "0"
    @State private var isCreateProductDialogPresented = false
    @State private var titleInput = ""
    @State private var placeholderInput = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var url = ""
    @State private var presentAlert = false
    @State private var isLoading = false

    var popupTitle: String {
        switch viewModel.popupType {
        case .instagramLink:
            return "Instagram Popup"
        case .twitterLink:
            return "Twitter Popup"
        case .youtubeLink:
            return "YouTube Popup"
        case .none:
            return "Popup"
        }
    }

    init() {
        WidgetsJSManager.shared.load(link: "https://platform.twitter.com/widgets.js", type: "tw")
        WidgetsJSManager.shared.load(link: "https://platform.instagram.com/en_US/embeds.js", type: "ig")
    }

    private var productsBinding: Binding<[ProductModel]> {
        $products.dispatched(to: container.appState, \.products)
    }

    private var filteredProducts: [ProductModel] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()

                    TextField("Search", text: $searchText)
                        .padding(.horizontal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom)

                    List(filteredProducts) { product in
                        NavigationLink(destination: ProductDetailView(product: product).inject(container)) {
                            HStack(spacing: 16) {
                                RemoteImage(url: URL(string: product.image)!)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(product.title)
                                        .font(.headline)

                                    Text(product.description)
                                        .font(.body)
                                        .padding(.bottom, 8)

                                    HStack {
                                        Text("Rate: \(product.rating.rate)")
                                        Text(String(format: "Price: $%.2f", product.price))
                                    }
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .navigationBarTitle("Product List")

                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button(action: {
                            isCreateProductDialogPresented = true
                            print("Create new product tapped!")
                        }) {
                            Text("Create Product")
                                .font(.headline)
                        }
                        Spacer()
                    }
                }
                .sheet(isPresented: $isCreateProductDialogPresented) {
                    NavigationView {
                        VStack {
                            ZStack {
                                Color.yellow.opacity(0.7)
                                    .edgesIgnoringSafeArea(.all)
                                HStack {
                                    Button(action: {
                                        print("memo")
                                    }) {
                                        Text("memo")
                                            .bold()
                                            .padding()
                                            .background(Color.white)
                                            .foregroundColor(.yellow)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .stroke(Color.white, lineWidth: 2)
                                            )
                                    }
                                    .frame(maxHeight: 20)
                                    .background(Color.yellow)
                                    .cornerRadius(80)
                                    .padding(.leading, 10)

                                    Spacer()
                                }

                                HStack {
                                    let formatingDate = getFormattedDate(date: Date(), format: "yyyy/MM/dd HH:MM")
                                    Text(formatingDate).font(.system(size: 12)).foregroundColor(Color.black.opacity(0.7))
                                }

                                HStack {
                                    Spacer()
                                    NavigationLink(destination: ExportEditorView(store: store, format: OutputFormat.json)) {
                                        Text("Export")
                                            .bold()
                                            .padding()
                                            .foregroundColor(Color.black)
                                    }
                                    .frame(maxHeight: 20)
                                    .padding(.trailing, 10)
                                }
                            }
                            .frame(maxHeight: 50)

                            TextField(
                                "Title",
                                text: $titleInput
                            )
                            .padding()

                            LexicalText(store: store, viewModel: viewModel)
                                .alert(popupTitle, isPresented: Binding<Bool>(
                                    get: { viewModel.didPressButton },
                                    set: { viewModel.didPressButton = $0 }
                                ), actions: {
                                    TextField("Link", text: $url)
                                    Button("Okay", action: {
                                        switch viewModel.popupType {
                                        case .instagramLink:
                                            addIG(link: url)
                                        case .twitterLink:
                                            addTwitter(link: url)
                                        case .youtubeLink:
                                            addYoutube(link: url)
                                        case .none:
                                            break
                                        }
                                    })
                                    Button("Cancel", role: .cancel, action: {})
                                }, message: {
                                    Text("Please enter your link.")
                                })
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button("Profile") {
                                print("Profile tapped!")
                            }
                            Button("Log out") {
                                print("Log out tapped!")
                                Task {
                                    do {
                                        container.interactors.authService!.signOut()
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        VStack {
                            NavigationLink(destination: CartView().inject(container)) {
                                ZStack {
                                    Image(systemName: "cart")
                                        .font(.title)
                                    Text(cartCount)
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 10, y: -10)
                                }
                            }
                        }
                    }
                }.modifier(ActivityIndicatorModifier(isLoading: isLoading))
            }
            .onReceive(productsUpdate) { updatedProducts in
                products = updatedProducts
            }
            .onReceive(cartUpdate) { updatedCarts in
                cartCount = String(updatedCarts.count)
            }
            .onAppear {
                fetchProducts()
            }
        }

    }

    func getFormattedDate(date: Date, format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: date)
    }

    private func fetchProducts() {
        container.interactors.productService.fetchProducts()
    }

    private func addTwitter(link: String) {
//        isLoading = true
        var originalSelection: RangeSelection?
        guard let editor = store.view?.editor else { return }

        do {
            try editor.read {
                originalSelection = try getSelection() as? RangeSelection
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        store.dispatchCommand(type: .insertTwitter, payload: TwitterPayload(urlString: link, htmlString: GetHTMLEmbeddedService.shared.html, size: CGSize(width: 550, height: 900), originalSelection: originalSelection))

        GetHTMLEmbeddedService.shared.loadTweetAndMeasureHeight(url: link) { height in
            store.dispatchCommand(type: .insertTwitter, payload: TwitterPayload(urlString: link, htmlString: GetHTMLEmbeddedService.shared.html, size: CGSize(width: UIScreen.screenSize.width, height: CGFloat(height!)), originalSelection: originalSelection))
            isLoading = false
        }
        url = ""
    }
    
    private func addIG(link: String) {
        var originalSelection: RangeSelection?
        guard let editor = store.view?.editor else { return }

        do {
            try editor.read {
                originalSelection = try getSelection() as? RangeSelection
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }

        store.dispatchCommand(type: .insertInstagram, payload: InstagramPayload(urlString: link, htmlString: "", size: CGSize(width: UIScreen.screenSize.width, height: 620), originalSelection: originalSelection))
        url = ""
    }
    
    private func addYoutube(link: String) {
        var originalSelection: RangeSelection?
        guard let editor = store.view?.editor else { return }

        do {
            try editor.read {
                originalSelection = try getSelection() as? RangeSelection
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        store.dispatchCommand(type: .insertYoutube, payload: YoutubePayload(urlString: link, htmlString: "", size: CGSize(width: 560, height: 315), originalSelection: originalSelection))
        url = ""
    }

}

private extension HomeView {
    var productsUpdate: AnyPublisher<[ProductModel], Never> {
        container.appState.updates(for: \.products)
    }

    var cartUpdate: AnyPublisher<[ProductModel], Never> {
        container.appState.updates(for: \.cart)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().inject(.preview)
    }
}

struct RemoteImage: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct ActivityIndicatorModifier: AnimatableModifier {
    var isLoading: Bool

    init(isLoading: Bool, color: Color = .primary, lineWidth: CGFloat = 3) {
        self.isLoading = isLoading
    }

    var animatableData: Bool {
        get { isLoading }
        set { isLoading = newValue }
    }

    func body(content: Content) -> some View {
        ZStack {
            if isLoading {
                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        content
                            .disabled(self.isLoading)
                            .blur(radius: self.isLoading ? 3 : 0)

                        VStack {
                            Text("Now Loading")
                            ActivityIndicator(isAnimating: .constant(true), style: .large)
                        }
                        .frame(width: geometry.size.width / 2,
                               height: geometry.size.height / 5)
                        .background(Color.secondary.colorInvert())
                        .foregroundColor(Color.primary)
                        .cornerRadius(20)
                        .opacity(self.isLoading ? 1 : 0)
                        .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                    }
                }
            } else {
                content
            }
        }
    }
}
