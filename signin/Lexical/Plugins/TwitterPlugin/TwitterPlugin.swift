import Foundation
import Lexical

extension CommandType {
  public static let insertTwitter = CommandType(rawValue: "insertTwitter")
}

public struct TwitterPayload {
  let urlString: String?
  let htmlString: String?
  let originalSelection: RangeSelection?
  let size: CGSize?

  public init(urlString: String?, htmlString: String?,size: CGSize?, originalSelection: RangeSelection?) {
    self.urlString = urlString
    self.htmlString = htmlString
    self.originalSelection = originalSelection
    self.size = size
  }
}

open class TwitterPlugin: Plugin {
    public init() {}

    weak var editor: Editor?
    public weak var lexicalView: LexicalView?

    public func setUp(editor: Editor) {
        self.editor = editor

        do {
            try editor.registerNode(nodeType: NodeType.selectableTwitter, class: SelectableTwitterNode.self)
        } catch {
            editor.log(.other, .error, "\(error)")
        }

        _ = editor.registerCommand(type: .insertTwitter, listener: { [weak self] payload in
          guard let strongSelf = self,
                let twitterPayload = payload as? TwitterPayload,
                let editor = strongSelf.editor
          else { return false }

          strongSelf.insertTwitter(payload: twitterPayload, editor: editor)
          return true
        })
    }

    public func tearDown() {}

    public static func isTwitterNode(_ node: Node?) -> Bool {
        node is SelectableTwitterNode
    }

    func insertTwitter(payload: TwitterPayload?, editor: Editor) {
      do {
        try editor.update {
            getActiveEditorState()?.selection = payload?.originalSelection
            let twitterNode = SelectableTwitterNode(url: payload?.urlString ?? "", html: payload?.htmlString ?? "", size: payload?.size ?? CGSize.zero)
            let selectedNodes = try getActiveEditorState()?.selection?.getNodes()
            guard let firstNode = selectedNodes?.first else { return }
            _ = try firstNode.insertBefore(nodeToInsert: twitterNode)
            self.lexicalView?.showPlaceholderText()
        }
      } catch {
        print("\(error)")
      }
    }
}
