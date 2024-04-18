import Foundation
import Lexical

extension CommandType {
  public static let insertYoutube = CommandType(rawValue: "insertYoutube")
}

public struct YoutubePayload {
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

open class YoutubePlugin: Plugin {
    public init() {}

    weak var editor: Editor?
    public weak var lexicalView: LexicalView?

    public func setUp(editor: Editor) {
        self.editor = editor

        do {
            try editor.registerNode(nodeType: NodeType.selectableYoutube, class: SelectableYoutubeNode.self)
        } catch {
            editor.log(.other, .error, "\(error)")
        }

        _ = editor.registerCommand(type: .insertYoutube, listener: { [weak self] payload in
          guard let strongSelf = self,
                let youtubePayload = payload as? YoutubePayload,
                let editor = strongSelf.editor
          else { return false }

          strongSelf.insertYoutube(payload: youtubePayload, editor: editor)
          return true
        })
    }

    public func tearDown() {}

    public static func isYoutubeNode(_ node: Node?) -> Bool {
        node is SelectableYoutubeNode
    }

    func insertYoutube(payload: YoutubePayload?, editor: Editor) {
      do {
        try editor.update {
            getActiveEditorState()?.selection = payload?.originalSelection
            let youtubeNode = SelectableYoutubeNode(url: payload?.urlString ?? "", html: payload?.htmlString ?? "", size: payload?.size ?? CGSize.zero)
            let selectedNodes = try getActiveEditorState()?.selection?.getNodes()
            guard let firstNode = selectedNodes?.first else { return }
            _ = try firstNode.insertBefore(nodeToInsert: youtubeNode)
            self.lexicalView?.showPlaceholderText()
        }
      } catch {
        print("\(error)")
      }
    }
}
