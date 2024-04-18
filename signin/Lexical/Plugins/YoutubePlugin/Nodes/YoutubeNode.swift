import AVFoundation
import WebKit
import Foundation
import Lexical
import LexicalHTML
import SwiftSoup
import SwiftUI
import UIKit
import Alamofire
import WebKit
import youtube_ios_player_helper

extension NodeType {
    static let selectableYoutube = NodeType(rawValue: "selectableYoutube")
}

let DEFAULT_YOUTUBE_WIDTH = 560
let DEFAULT_YOUTUBE_HEIGHT = 315

public class SelectableYoutubeNode: CustomSelectableDecoratorNode {
    var url: URL?
    var html: String?
    var id: String?
    var size = CGSize.zero

    private func getIdFromURL(url: String) -> String? {
        let regExp = try! NSRegularExpression(pattern: #"^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*"#)
        if let match = regExp.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) {
            let idRange = Range(match.range(at: 2), in: url)!
            let id = String(url[idRange])
            return id.count == 11 ? id : nil
        }
        return nil
    }

    public required init(url: String, html: String, size: CGSize, key: NodeKey? = nil) {
        super.init(key)

        self.id = getIdFromURL(url: url)
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
        return .selectableYoutube
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    override public func clone() -> Self {
        Self(url: url?.absoluteString ?? "", html: html ?? "", size: size, key: key)
    }

    override public func createContentView() -> UIView {
        return createYoutubeView()
    }

    public func getURL() -> String? {
        let latest = getLatest()
        return latest.url?.absoluteString
    }

    public func setURL(_ url: String) throws {
        try errorOnReadOnly()

        try getWritable().url = URL(string: url)
    }

    private func createYoutubeView() -> UIView {
        let htmtYoutube = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>* { margin: 0; padding: 0; } </style></head><body><div id='wrapper' display: 'inline-block'><iframe width='100%' height='\(DEFAULT_YOUTUBE_WIDTH)' src='https://www.youtube.com/embed/\(id!)' allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture' allowFullScreen={true} title='YouTube video' style={{ pointerEvents: 'none' }} /></div></body></html>"

        let webView = WKWebView()
        webView.isUserInteractionEnabled = false
        webView.frame = CGRect(x: 0, y: 0, width: DEFAULT_YOUTUBE_WIDTH, height: DEFAULT_YOUTUBE_HEIGHT)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        webView.loadHTMLString(htmtYoutube, baseURL: nil)
        return webView
    }

    override open func decorateContentView(view: UIView, wrapper: CustomSelectableDecoratorView) {
      // not code
    }

    private func getDataURL() -> String {
        return "https://www.youtube.com/embed/\(id!)"
    }

    let maxImageHeight: CGFloat = 600.0

    override open func sizeForDecoratorView(textViewWidth: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGSize {

      if size.width <= textViewWidth {
        return size
      }
      return AVMakeRect(aspectRatio: size, insideRect: CGRect(x: 0, y: 0, width: textViewWidth, height: maxImageHeight)).size
    }
}

extension SelectableYoutubeNode: NodeHTMLSupport {
    public static func importDOM(domNode _: SwiftSoup.Node) throws -> DOMConversionOutput {
        return (after: nil, forChild: nil, node: [])
    }

    public func exportDOM(editor _: Lexical.Editor) throws -> DOMExportOutput {
        let dom = SwiftSoup.Element(Tag("div"), "")
        try dom.attr("class", "embed-youtube")
        try dom.attr("data-url", getDataURL())
        return (after: nil, element: dom)
    }
}
