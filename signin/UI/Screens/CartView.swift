import SwiftUI
import Combine

struct CartItem: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let price: Double
    var quantity: Int
}

struct CartView: View {
    @Environment(\.injected) private var container: DIContainer
    @State private var products: [ProductModel] = []

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(products) { item in
                        CartRow(item: item)
                    }
                }
                Spacer()
                TotalView(items: products)
                NavigationLink(destination: CheckoutView()) {
                    Text("Proceed to Checkout")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Cart")
        }
        .onReceive(cartUpdate) { updatedCarts in
            products = updatedCarts
        }
    }
}

extension CartView {
    fileprivate var cartUpdate: AnyPublisher<[ProductModel], Never> {
        container.appState.updates(for: \.cart)
    }
}


struct CartRow: View {
    let item: ProductModel
    
    var body: some View {
        HStack(spacing: 16) {
            RemoteImage(url: URL(string: item.image)!)
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(String(format: "$%.2f", item.price))
                    .font(.subheadline)
                HStack {
                    Text("Quantity: 1")
                        .font(.caption)
                    Spacer() // Add Spacer here
                    Text("Total: \(String(format: "$%.2f", item.price))")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct TotalView: View {
    let items: [ProductModel]

    var total: Double {
        items.reduce(0) { $0 + ($1.price) }
    }

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing) {
                Text("Total:")
                    .font(.headline)
                Text(String(format: "$%.2f", total))
                    .font(.headline)
            }
            .padding(.trailing)
        }
    }
}

struct CheckoutView: View {
    var body: some View {
        Text("Checkout")
            .navigationTitle("Checkout")
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
