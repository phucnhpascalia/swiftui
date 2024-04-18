import Foundation
import Lexical
import SwiftUI
import EditorHistoryPlugin
import LexicalInlineImagePlugin
import LexicalLinkPlugin
import Combine
import UIKit

class LexicalStore: ObservableObject {
    weak var view: LexicalView?
    let theme: Theme

    @Published var isBold = false
    @Published var isItalic = false
    @Published var isFocus = false

    init() {
        theme = Theme()
        theme.paragraph = [
            .fontSize: 18.0,
            .lineHeight: 18.0,
        ]
        theme.link = [
            .foregroundColor: Color.blue,
        ]
    }

    var editorState: EditorState? {
        view?.editor.getEditorState()
    }

    var editor: Editor? {
        view?.editor
    }

    func dispatchCommand(type: CommandType, payload: Any?) {
        view?.editor.dispatchCommand(type: type, payload: payload)
    }

    func update(closure: @escaping () throws -> Void) throws {
        try view?.editor.update(closure)
    }
}

struct LexicalText: UIViewRepresentable {
    public var store: LexicalStore
    @ObservedObject var viewModel: MapViewModel

    func makeUIView(context _: Context) -> UIStackView {
        // Create a UIStackView
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8

        let editorHistoryPlugin = EditorHistoryPlugin()
        let hierarchyPlugin = NodeHierarchyViewPlugin()
        let toolbarPlugin = ToolbarPlugin(historyPlugin: editorHistoryPlugin, viewModel: viewModel)
        let twitterPlugin = TwitterPlugin()
        let instagramPlugin = InstagramPlugin()
        let youtubePlugin = YoutubePlugin()


        let view = LexicalView(
            editorConfig: EditorConfig(
                theme: store.theme,
                plugins: [toolbarPlugin, editorHistoryPlugin, hierarchyPlugin, twitterPlugin, instagramPlugin, youtubePlugin]
            ),
            featureFlags: FeatureFlags(),
            placeholderText: LexicalPlaceholderText(
                text: "Write a new description",
                font: .systemFont(ofSize: 18),
                color: UIColor.placeholderText
            )
        )

        store.view = view
        twitterPlugin.lexicalView = view
        instagramPlugin.lexicalView = view
        youtubePlugin.lexicalView = view

        _ = view.editor.registerUpdateListener { _, _, _ in
            updateStoreState()
        }

//        registerRichText(editor: view.editor)

        stackView.addArrangedSubview(view)
        stackView.addArrangedSubview(toolbarPlugin.toolbar)
//        stackView.addArrangedSubview(hierarchyPlugin.hierarchyView)

        return stackView
    }

    func updateUIView(_ uiView: UIStackView, context _: Context) {
        // Loop through arranged subviews of UIStackView
        for subview in uiView.arrangedSubviews {
            // Check if the subview is an instance of LexicalView
            if let lexicalView = subview as? LexicalView {
                // Now you have access to the LexicalView
                // You can perform any updates or actions on the LexicalView here
                lexicalView.placeholderText = LexicalPlaceholderText(
                    text: "...",
                    font: .systemFont(ofSize: 18),
                    color: UIColor.placeholderText
                )
            }
        }
    }

    func updateStoreState() {
        let rangeSelection = try? getSelection() as? RangeSelection
        if rangeSelection != nil {
            store.isBold = rangeSelection?.hasFormat(type: .bold) ?? false
        }
    }

    public func registerRichText(editor: Editor) {
        _ = editor.registerCommand(type: .keyEnter, listener: { [weak editor] payload in
          guard let editor else { return false }
          do {
            print("test enter")
            return true
          } catch {
            print("\(error)")
          }
          return true
        }, priority: CommandPriority.High)

      _ = editor.registerCommand(type: .deleteCharacter, listener: { [weak editor] payload in
          guard let editor else { return false }

          do {
              try editor.read {
                  if let selection = try getSelection() {
                      let selectedNodes = try selection.getNodes()
//                      guard var firstNode = selectedNodes.first as? SelectableTwitterNode else { return }
//                      print(firstNode.getURL())
                  }
              }
          } catch {
              // Handle errors here
              print("Error: \(error.localizedDescription)")
          }
          
          
        return true
      }, priority: CommandPriority.High)

      _ = editor.registerCommand(type: .deleteWord, listener: { [weak editor] payload in
        guard let editor else { return false }
        do {
            print("deleteWord test")
          return true
        } catch {
          print("\(error)")
        }
        return true
      }, priority: CommandPriority.High)

      _ = editor.registerCommand(type: .deleteLine, listener: { [weak editor] payload in
        guard let editor else { return false }
        do {
            print("deleteLine test")
          return true
        } catch {
          print("\(error)")
        }
        return true
      }, priority: CommandPriority.High)
        
        _ = editor.registerCommand(type: .insertText, listener: { [weak editor] payload in
          guard let editor else { return false }
          do {
            guard let text = payload as? String else {
              editor.log(.TextView, .warning, "insertText missing payload")
              return false
            }

              print("insertText test")
            return true
          } catch {
            editor.log(.TextView, .error, "Exception in insertText; \(String(describing: error))")
          }
          return true
        }, priority: CommandPriority.High)

        _ = editor.registerCommand(type: .insertParagraph, listener: { [weak editor] payload in
          guard let editor else { return false }
          do {
              print("insertParagraph test")
            return true
          } catch {
            print("\(error)")
          }
          return true
        }, priority: CommandPriority.High)
    }
}
