import SwiftUI
import Combine

struct ProductDetailView: View {
    var product: ProductModel

    @Environment(\.injected) private var container: DIContainer
    @Environment(\.presentationMode) var presentationMode
    @State private var cartCount = "0"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
                    RemoteImage(url: URL(string: product.image)!)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .padding(.bottom, 8)

                    Text(product.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    Text(product.description)
                        .font(.body)
                        .padding(.bottom, 8)
                    HStack {
                        Text("Rate: \(product.rating.rate)")
                        Spacer()
                        Text("Price: $\(product.price)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)

                    Button(action: {
                        addToCart(product: product)
                    }) {
                        Text("Add to Cart")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Product Detail")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.blue)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: CartView()) {
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
        .onReceive(cartUpdate) { updatedCarts in
            cartCount = String(updatedCarts.count)
        }
    }

    private func addToCart(product: ProductModel) {
        container.interactors.cartService.addToCart(product: product)
    }
}

extension ProductDetailView {
    fileprivate var cartUpdate: AnyPublisher<[ProductModel], Never> {
        container.appState.updates(for: \.cart)
    }
}


struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: ProductModel(id: 1, title: "Product Title", price: 99.99, description: "Product Description", category: "Category", image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg", rating: RatingModel(rate: 4.5, count: 100)))
    }
}
