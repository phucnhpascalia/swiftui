import SwiftUI
import Combine
import Lexical
import LexicalHTML

internal enum OutputFormat: CaseIterable {
  case html
  case json

  var title: String {
    switch self {
    case .html: return "HTML"
    case .json: return "JSON"
    }
  }
}

struct ExportEditorView: View {
    private let storeLexical: LexicalStore
    var output: String = ""

    init(store: LexicalStore, format: OutputFormat) {
        self.storeLexical = store
        guard let editor = store.view?.editor else { return }

        switch format {
        case .html:
          generateHTML(editor: editor)
        case .json:
          generateJSON(editor: editor)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text(output)
                    .padding()
            }
            .navigationTitle("Export")
        }
    }

    private mutating func generateHTML(editor: Editor) {
      try? editor.read {
        do {
          self.output = try generateHTMLFromNodes(editor: editor, selection: nil)
        } catch let error {
          self.output = error.localizedDescription
        }
      }
    }

    private mutating func generateJSON(editor: Editor) {
      let currentEditorState = editor.getEditorState()
      if let jsonString = try? currentEditorState.toJSON() {
        output = jsonString
      } else {
        output = "Failed to generate JSON output"
      }
    }
}
