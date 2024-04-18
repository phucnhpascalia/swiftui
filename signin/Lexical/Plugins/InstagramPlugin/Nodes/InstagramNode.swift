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

extension NodeType {
    static let selectableInstagram = NodeType(rawValue: "selectableInstagram")
}

public class SelectableInstagramNode: CustomSelectableDecoratorNode {
    var url: URL?
    var html: String?
    var id: String?
    var size = CGSize.zero

    private func extractInstagramID(from text: String) -> String? {
        let pattern = "(?:https?://www\\.)?instagram\\.com\\S*?/p/(\\w+)/?"

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            if let match = matches.first {
                let idRange = Range(match.range(at: 1), in: text)!
                let id = String(text[idRange])
                return id
            }
        } catch {
            print("Error creating regular expression: \(error)")
        }

        return nil
    }


    public required init(url: String, html: String, size: CGSize, key: NodeKey? = nil) {
        super.init(key)

        self.id = extractInstagramID(from: url)
        print(id!)
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
        return .selectableInstagram
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    override public func clone() -> Self {
        Self(url: url?.absoluteString ?? "", html: html ?? "", size: size, key: key)
    }

    override public func createContentView() -> UIView {
        return createInstagramView()
    }

    public func getURL() -> String? {
        let latest = getLatest()
        return latest.url?.absoluteString
    }

    public func setURL(_ url: String) throws {
        try errorOnReadOnly()

        try getWritable().url = URL(string: url)
    }

    private func createInstagramView() -> UIView {
        let webView = InstagramView(id: id!)
        webView.isUserInteractionEnabled = false
        webView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        webView.load()
            return webView
    }

    override open func decorateContentView(view: UIView, wrapper: CustomSelectableDecoratorView) {
      // not code
    }

    private func getDataURL() -> String {
        return "https://www.instagram.com/p/\(id!)"
    }

    let maxImageHeight: CGFloat = 600.0

    override open func sizeForDecoratorView(textViewWidth: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGSize {

      if size.width <= textViewWidth {
        return size
      }
      return AVMakeRect(aspectRatio: size, insideRect: CGRect(x: 0, y: 0, width: textViewWidth, height: maxImageHeight)).size
    }
}

extension SelectableInstagramNode: NodeHTMLSupport {
    public static func importDOM(domNode _: SwiftSoup.Node) throws -> DOMConversionOutput {
        return (after: nil, forChild: nil, node: [])
    }

    public func exportDOM(editor _: Lexical.Editor) throws -> DOMExportOutput {
        let dom = SwiftSoup.Element(Tag("div"), "")
        try dom.attr("class", "embed-ig")
        try dom.attr("data-url", getDataURL())
        return (after: nil, element: dom)
    }
}
