import SwiftUI
import Combine

struct HomeView: View {
    @Environment(\.injected) private var container: DIContainer
    @State private var searchText = ""
    @State private var products: [ProductModel] = []
    @State private var cartCount = "0"

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
            }
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

    private func fetchProducts() {
        container.interactors.productService.fetchProducts()
    }
}

extension HomeView {
    fileprivate var productsUpdate: AnyPublisher<[ProductModel], Never> {
        container.appState.updates(for: \.products)
    }

    fileprivate var cartUpdate: AnyPublisher<[ProductModel], Never> {
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
