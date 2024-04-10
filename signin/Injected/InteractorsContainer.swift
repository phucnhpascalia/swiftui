struct Interactors {
    let productService: ProductServiceProtocol
    let cartService: CartServiceProtocol
    let authService: AuthService?

    init(productService: ProductServiceProtocol, cartService: CartServiceProtocol, authService: AuthService? = nil) {
        self.productService = productService
        self.authService = authService
        self.cartService = cartService
    }

    static var stub: Self {
        .init(productService: StubProductServiceImpl(), cartService: StubCartServiceImpl())
    }
}
