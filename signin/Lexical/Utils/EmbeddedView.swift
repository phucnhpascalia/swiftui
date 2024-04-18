import SafariServices
import UIKit
import WebKit

private let DefaultCellHeight: CGFloat = 20
private let ViewPadding: CGFloat = 40

private let HeightCallback = "heightCallback"
private let ClickCallback = "clickCallback"
let HtmlTemplate = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>* { margin: 0; padding: 0; } div { background-color: grey; width: 100% !important; max-width: 100% !important; min-width: 100% !important; } twitterwidget::shadow .EmbeddedTweet { width: 100% !important; max-width: 100% !important; min-width: 100% !important; } div twitterwidget { width: 100% !important; max-width: 100% !important; min-width: 100% !important; }</style></head><body><div id='wrapper' display: 'inline-block'></div></body></html>"

private let HtmlTemplateIG = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>* { margin: 0; padding: 0; } </style></head><body><div id='wrapper' display: 'inline-block'><blockquote className='instagram-media' data-instgrm-captioned data-instgrm-permalink={'https://www.instagram.com/p/C5zuPj5Leek/'} data-instgrm-version='12' /></div></body></html>"

@objc
public protocol EmbeddedViewDelegate: AnyObject {
    func embeddedView(_ embeddedView: EmbeddedView, didUpdatedHeight height: CGFloat)
    func embeddedView(_ embeddedView: EmbeddedView, shouldOpenURL url: URL)
    func embeddedView(_ embeddedView: EmbeddedView, didFinishProcessingHeight height: CGFloat)
}

public class EmbeddedView: UIView {
    // The WKWebView we'll use to display the embed
    private lazy var webView: WKWebView! = {
        let webView = WKWebView()

        webView.isOpaque = false

        // Set delegates
        webView.navigationDelegate = self
        webView.uiDelegate = self

        // Register callbacks
        webView.configuration.userContentController.add(self, name: ClickCallback)
        webView.configuration.userContentController.add(self, name: HeightCallback)

        // Set initial frame
        webView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat(DefaultCellHeight))

        // Prevent scrolling
        webView.scrollView.isScrollEnabled = false

        return webView
    }()

    /// The EmbeddedView Delegate
    @IBInspectable public weak var delegate: EmbeddedViewDelegate?

    /// The Embed ID
    @IBInspectable public var id: String

    /// The Embed Type
    @IBInspectable public var embedType: String

    /// The Embed Max Width
    @IBInspectable public var maxWidth: Int

    /// The state of the EmbeddedView
    public private(set) var state: State = .idle

    /// The height of the EmbeddedView
    public private(set) var height: CGFloat {
        didSet {
            delegate?.embeddedView(self, didUpdatedHeight: height)
        }
    }

    /// Initializes and returns a newly allocated embed view object with the specified id
    /// - Parameter id: Embed id
    /// - Parameter type: Embed type
    public init(id: String, type: String, maxWidth: Int) {
        self.id = id
        self.embedType = type
        self.maxWidth = maxWidth
        height = DefaultCellHeight

        super.init(frame: CGRect.zero)
    }

    public required init?(coder: NSCoder) {
        id = ""
        embedType = ""
        maxWidth = 0
        height = DefaultCellHeight

        super.init(coder: coder)
    }

    // MARK: Methods

    /// Load the Embed HTML template
    public func load() {
        guard state != .loading else { return }
        state = .loading
        addWebViewToSubviews()

        webView.loadHTMLString(HtmlTemplateIG, baseURL: nil)
    }

    fileprivate func addWebViewToSubviews() {
        addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    // IG Loader
    private func loadIGInWebView(_ webView: WKWebView) {
        if let widgetsJSScript = WidgetsJSManager.shared.contentIG {
            webView.evaluateJavaScript(widgetsJSScript)
            webView.evaluateJavaScript("window.instgrm.Embeds.process();")
        }
    }

    // Tweet Loader
    private func loadTweetInWebView(_ webView: WKWebView) {
        if let widgetsJSScript = WidgetsJSManager.shared.contentTW {
            webView.evaluateJavaScript(widgetsJSScript)
            webView.evaluateJavaScript("twttr.widgets.load();")

            var theme = "light"
            if #available(iOS 13.0, *), UITraitCollection.current.userInterfaceStyle == .dark {
                theme = "dark"
            }

            // Documentation:
            // https://developer.twitter.com/en/docs/twitter-for-websites/embedded-tweets/guides/embedded-tweet-javascript-factory-function
            webView.evaluateJavaScript("""
                twttr.widgets.createTweet(
                    '\(id)',
                    document.getElementById('wrapper'),
                    { align: 'center', theme: '\(theme)', width: 800 }
                ).then(el => {
                    window.webkit.messageHandlers.heightCallback.postMessage({ height: el.offsetHeight.toString(), width: el.offsetWidth.toString() });
                });
            """)
        }
    }
}

// MARK: - WKNavigationDelegate

extension EmbeddedView: WKNavigationDelegate {
    public func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
            delegate?.embeddedView(self, shouldOpenURL: url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    public func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        switch embedType {
        case "tweet":
            loadTweetInWebView(webView)
        case "IG":
            loadIGInWebView(webView)
        default:
            print("Unhandled loaded")
        }

        state = .loaded
    }

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        state = .failed
    }
}

// MARK: - WKUIDelegate

extension EmbeddedView: WKUIDelegate {
    public func webView(_: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        // Allow links with target="_blank" to open in SafariViewController
        //   (includes clicks on the background of Embedded View
        if let url = navigationAction.request.url, navigationAction.targetFrame == nil {
            delegate?.embeddedView(self, shouldOpenURL: url)
        }

        return nil
    }
}

// MARK: - WKScriptMessageHandler

extension EmbeddedView: WKScriptMessageHandler {
    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        print("tesssss phucccc")

        switch message.name {
        case HeightCallback:
            guard let messageBody = message.body as? [String: String],
                          let heightString = messageBody["height"],
                          let widthString = messageBody["width"],
                          let intHeight = Int(heightString),
                          let intWidth = Int(widthString) else { return }
            height = CGFloat(intHeight) + ViewPadding
            delegate?.embeddedView(self, didFinishProcessingHeight: height)

        default:
            print("Unhandled callback")
        }
    }
}

public extension EmbeddedView {
    enum State {
        case idle, loading, loaded, failed
    }
}
