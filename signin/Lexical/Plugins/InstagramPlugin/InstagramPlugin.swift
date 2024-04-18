import Foundation
import Lexical

extension CommandType {
  public static let insertInstagram = CommandType(rawValue: "insertInstagram")
}

public struct InstagramPayload {
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

open class InstagramPlugin: Plugin {
    public init() {}

    weak var editor: Editor?
    public weak var lexicalView: LexicalView?

    public func setUp(editor: Editor) {
        self.editor = editor

        do {
            try editor.registerNode(nodeType: NodeType.selectableInstagram, class: SelectableInstagramNode.self)
        } catch {
            editor.log(.other, .error, "\(error)")
        }

        _ = editor.registerCommand(type: .insertInstagram, listener: { [weak self] payload in
          guard let strongSelf = self,
                let instagramPayload = payload as? InstagramPayload,
                let editor = strongSelf.editor
          else { return false }

          strongSelf.insertInstagram(payload: instagramPayload, editor: editor)
          return true
        })
    }

    public func tearDown() {}

    public static func isInstagramNode(_ node: Node?) -> Bool {
        node is SelectableInstagramNode
    }

    func insertInstagram(payload: InstagramPayload?, editor: Editor) {
      do {
        try editor.update {
            getActiveEditorState()?.selection = payload?.originalSelection
            let instagramNode = SelectableInstagramNode(url: payload?.urlString ?? "", html: payload?.htmlString ?? "", size: payload?.size ?? CGSize.zero)
            let selectedNodes = try getActiveEditorState()?.selection?.getNodes()
            guard let firstNode = selectedNodes?.first else { return }
            _ = try firstNode.insertBefore(nodeToInsert: instagramNode)
            self.lexicalView?.showPlaceholderText()
        }
      } catch {
        print("\(error)")
      }
    }
}
