import UIKit
import Alamofire
import WebKit

class GetHTMLEmbeddedService: NSObject {
    typealias CompletionHandler = (CGFloat?) -> Void
    var completionHandler: CompletionHandler?

    static let shared = GetHTMLEmbeddedService()

    private(set) var height: CGFloat?
    private(set) var html: String?
    private(set) var id: String?

    private var webView: WKWebView?
    private let DefaultCellHeight: CGFloat = 20
    private let ViewPadding: CGFloat = 120
    private let HeightCallback = "heightCallback"
    private let HtmlTemplate = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>* { margin: 0; padding: 0; } </style></head><body><div id='wrapper' display: 'inline-block'></div></body></html>"

    private override init() {
        super.init()
    }

    func loadTweetAndMeasureHeight(url: String, completion: @escaping (CGFloat?) -> Void) {
        let twitterUrl = "https://publish.twitter.com/oembed?hide_thread=true&maxwidth=100%&maxheight=100%&url=\(url)"
        let webView = WKWebView()
        webView.isHidden = true
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.frame = CGRect(x: 0, y: 0, width: CGFloat(DefaultCellHeight), height: CGFloat(DefaultCellHeight))

        AF.request(twitterUrl).responseJSON { [weak self] response in
            guard let self = self else { return }
            self.completionHandler = completion

            switch response.result {
            case .success(let JSON):
                if let response = JSON as? NSDictionary, let html = response.object(forKey: "html") as? String, let url = response.object(forKey: "url") as? String {
                    self.html = html
                    let components = url.components(separatedBy: "/")
                    self.id = components.last;

                    webView.configuration.userContentController.add(self, name: HeightCallback)
                    webView.loadHTMLString(HtmlTemplate, baseURL: nil)

                    self.webView = webView
                }
            case .failure(let error):
                print("Error loading tweet:", error)
            }
        }
    }
}

extension GetHTMLEmbeddedService: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
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
                    '\(id!)',
                    document.getElementById('wrapper'),
                    { align: 'center', theme: '\(theme)', width: 800 }
                ).then(el => {

                    window.webkit.messageHandlers.heightCallback.postMessage(el.offsetHeight.toString())
                });
            """)
        }
    }

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        print("load fail")
    }
}

extension GetHTMLEmbeddedService: WKScriptMessageHandler {
    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case HeightCallback:
            guard let message = message.body as? String, let intHeight = Int(message) else { return }
            height = CGFloat(intHeight) + ViewPadding
            webView?.removeFromSuperview()
            webView = nil
            completionHandler?(height)

        default:
            print("Unhandled callback")
        }
    }
}
