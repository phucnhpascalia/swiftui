import AVFoundation
import WebKit
import Foundation
import Lexical
import LexicalHTML
import SwiftSoup
import SwiftUI
import UIKit
import Alamofire

extension NodeType {
    static let selectableTwitter = NodeType(rawValue: "selectableTwitter")
}

public class SelectableTwitterNode: CustomSelectableDecoratorNode {
    var url: URL?
    var html: String?
    var id: String?
    var owner: String?
    var size = CGSize.zero

    public required init(url: String, html: String, size: CGSize, key: NodeKey? = nil) {
        super.init(key)
        if let match = url.range(of: "^https://twitter.com/(#!/)?(\\w+)/status(es)?/(\\d+)(\\?.*)?/?$", options: .regularExpression) {
            let urlString = String(url[match])
            let groups = urlString.components(separatedBy: "/")
            print(groups)
            if groups.count > 5 {
                owner = groups[3]
                id = groups[5]
            }
        }

        self.url = URL(string: url)
        self.size = size
        self.html = html
    }

    required init(_ key: NodeKey? = nil) {
        super.init(key)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override public class func getType() -> NodeType {
        return .selectableTwitter
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    override public func clone() -> Self {
        Self(url: url?.absoluteString ?? "", html: html ?? "", size: size, key: key)
    }

    override public func createContentView() -> UIView {
        return createTwitterView()
    }

    public func getURL() -> String? {
        let latest = getLatest()
        return latest.url?.absoluteString
    }

    public func setURL(_ url: String) throws {
        try errorOnReadOnly()

        try getWritable().url = URL(string: url)
    }

    private func createTwitterView() -> UIView {
//        let webView = EmbeddedView(id: id ?? "", type: "tweet", maxWidth: Int(size.width))
//        webView.isUserInteractionEnabled = false
//        webView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        webView.load()

        let webView = WKWebView()
            if let html = html {
                webView.isUserInteractionEnabled = false
                webView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                let urlTwitter = getDataURL()
                webView.loadHTMLString("<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head><body><div id='wrapper' display: 'inline-block'><blockquote class='twitter-tweet' data-lang='en'><a href='\(urlTwitter)'></a></blockquote></div><script async src='https://platform.twitter.com/widgets.js'></script></body></html>", baseURL: nil)
            }
            return webView
    }

    override open func decorateContentView(view: UIView, wrapper: CustomSelectableDecoratorView) {
      // not code
    }

    private func getDataURL() -> String {
        return "https://twitter.com/\(owner!)/status/\(id!)"
    }

    let maxImageHeight: CGFloat = 600.0

    override open func sizeForDecoratorView(textViewWidth: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGSize {

      if size.width <= textViewWidth {
        return size
      }
      return AVMakeRect(aspectRatio: size, insideRect: CGRect(x: 0, y: 0, width: textViewWidth, height: maxImageHeight)).size
    }
}

extension SelectableTwitterNode: NodeHTMLSupport {
    public static func importDOM(domNode _: SwiftSoup.Node) throws -> DOMConversionOutput {
        return (after: nil, forChild: nil, node: [])
    }

    public func exportDOM(editor _: Lexical.Editor) throws -> DOMExportOutput {
        let dom = SwiftSoup.Element(Tag("div"), "")
        try dom.attr("class", "embed-twitter")
        try dom.attr("data-url", getDataURL())
        return (after: nil, element: dom)
    }
}
