import SafariServices
import UIKit
import WebKit

private let DefaultCellHeight: CGFloat = 20
private let ViewPadding: CGFloat = 40

let HtmlTemplateIGView = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>* { margin: 0; padding: 0; } #wrapper { margin: 0 !important; padding: 0 !important; width: 100% !important; } iframe { width: 100% !important; }</style></head><body><div id='wrapper' display: 'inline-block'><blockquote class='instagram-media' data-instgrm-captioned data-instgrm-permalink='https://www.instagram.com/p/%s' data-instgrm-version='12' /></div><script async src='//www.instagram.com/embed.js'></script></body></html>"

public class InstagramView: UIView {
    // The WKWebView we'll use to display the embed
    private lazy var webView: WKWebView! = {
        let webView = WKWebView()

        webView.isOpaque = false

        // Set delegates
        webView.navigationDelegate = self

        // Set initial frame
        webView.frame = CGRect(x: 0, y: 0, width: CGFloat(DefaultCellHeight), height: CGFloat(DefaultCellHeight))

        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Prevent scrolling
        webView.scrollView.isScrollEnabled = false

        return webView
    }()

    @IBInspectable public var id: String

    public private(set) var state: State = .idle

    public private(set) var height: CGFloat

    public init(id: String) {
        self.id = id
        height = DefaultCellHeight

        super.init(frame: CGRect.zero)
    }

    public required init?(coder: NSCoder) {
        id = ""
        height = DefaultCellHeight

        super.init(coder: coder)
    }

    // MARK: Methods

    /// Load the Embed HTML template
    public func load() {
        guard state != .loading else { return }
        state = .loading
        addWebViewToSubviews()

        let modifiedHtmlTemplate = HtmlTemplateIGView.replacingOccurrences(of: "%s", with: id)

        webView.loadHTMLString(modifiedHtmlTemplate, baseURL: nil)
    }

    fileprivate func addWebViewToSubviews() {
        addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func loadInWebView(_ webView: WKWebView) {
        if let widgetsJSScript = WidgetsJSManager.shared.contentIG {
            webView.evaluateJavaScript(widgetsJSScript)
            webView.evaluateJavaScript("window.instgrm.Embeds.process();")
        }
    }
}

// MARK: - WKNavigationDelegate

extension InstagramView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        loadInWebView(webView)

        state = .loaded
    }

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        state = .failed
    }
}

public extension InstagramView {
    enum State {
        case idle, loading, loaded, failed
    }
}
