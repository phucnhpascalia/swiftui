import EditorHistoryPlugin
import Foundation
import Lexical
import LexicalInlineImagePlugin
import LexicalLinkPlugin
import SelectableDecoratorNode
import UIKit
import Combine

public class ToolbarPlugin: Plugin {
    private var _toolbar: UIToolbar
    private var toolbarHeightConstraint: NSLayoutConstraint?
    private var viewModel: MapViewModel?

    weak var editor: Editor?
    weak var historyPlugin: EditorHistoryPlugin?

    init(historyPlugin: EditorHistoryPlugin?, viewModel: MapViewModel?) {
        _toolbar = UIToolbar()
        self.historyPlugin = historyPlugin
        self.viewModel = viewModel

        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        setUpToolbar()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        toolbar.isHidden = false

    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        toolbar.isHidden = true
    }

    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }

    public func setUp(editor: Editor) {
        self.editor = editor

        _ = editor.registerUpdateListener { [weak self] _, _, _ in
            if let self {
                self.updateToolbar()
            }
        }
    }

    public func tearDown() {}

    // MARK: - Public accessors

    public var toolbar: UIToolbar {
        _toolbar
    }

    // MARK: - Private helpers

    var linkButton: UIBarButtonItem?

    private func setUpToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 10

        let heading1Image = UIImage(named: "fa-heading")
        let resizedImage = heading1Image?.resized(to: CGSize(width: 20, height: 20))
        let heading2Image = UIImage(named: "fa-heading")
        let resizedImage2 = heading2Image?.resized(to: CGSize(width: 15, height: 15))
        let plusImage = UIImage(named: "fa-plus")
        let resizedPlusImage = plusImage?.resized(to: CGSize(width: 20, height: 20))

        let link = UIBarButtonItem(image: UIImage(systemName: "link"), style: .plain, target: self, action: #selector(link))
        let insertImage = UIBarButtonItem(image: UIImage(systemName: "photo"), menu: imageMenu)
        let heading1 = UIBarButtonItem(image: resizedImage, style: .plain, target: self, action: #selector(createHeading1Node))
        let heading2 = UIBarButtonItem(image: resizedImage2, style: .plain, target: self, action: #selector(createHeading2Node))
        let bold = UIBarButtonItem(image: UIImage(systemName: "bold"), style: .plain, target: self, action: #selector(toggleBold))
        let quote = UIBarButtonItem(image: UIImage(systemName: "quote.opening"), style: .plain, target: self, action: #selector(createQuoteNodeWrap))

        let plus = UIBarButtonItem(image: resizedPlusImage, menu: embeddedMenu)
        let textItem = UIBarButtonItem(title: "56文字", style: .plain, target: nil, action: nil)
        textItem.isEnabled = false

        let items: [UIBarButtonItem] = [insertImage, heading1, heading2, link, bold, quote, plus]
        for item in items {
            item.tintColor = UIColor.gray
        }

        var toolbarItems: [UIBarButtonItem] = []
        for (index, item) in items.enumerated() {
            toolbarItems.append(item)
            if index < items.count - 1 {
                toolbarItems.append(flexibleSpace)
            }
        }

        let dividerLabel = UILabel()
        dividerLabel.text = "|"
        dividerLabel.textColor = .gray
        dividerLabel.sizeToFit()

        let dividerContainerView = UIView(frame: CGRect(x: 0, y: 0, width: dividerLabel.bounds.width, height: dividerLabel.bounds.height))

        dividerLabel.frame = dividerContainerView.bounds
        dividerContainerView.addSubview(dividerLabel)

        let dividerItem = UIBarButtonItem(customView: dividerContainerView)

        toolbarItems.append(fixedSpace)
        toolbarItems.append(dividerItem)
        toolbarItems.append(textItem)

        _toolbar.barTintColor = UIColor.white
        toolbar.items = toolbarItems
        toolbar.isHidden = true
    }

    private enum ParagraphMenuSelectedItemType {
        case paragraph
        case h1
        case h2
        case code
        case quote
        case bullet
        case numbered
    }

    private var paragraphMenuSelectedItem: ParagraphMenuSelectedItemType = .paragraph

    private func updateToolbar() {
        if let selection = try? getSelection() as? RangeSelection {
            guard let anchorNode = try? selection.anchor.getNode() else { return }

            var element =
                isRootNode(node: anchorNode)
                    ? anchorNode
                    : findMatchingParent(startingNode: anchorNode, findFn: { e in
                        let parent = e.getParent()
                        return parent != nil && isRootNode(node: parent)
                    })

            if element == nil {
                element = anchorNode.getTopLevelElementOrThrow()
            }
            
            if let heading = element as? HeadingNode {
                if heading.getTag() == .h1 {
                    paragraphMenuSelectedItem = .h1
                } else {
                    paragraphMenuSelectedItem = .h2
                }
            } else if element is CodeNode {
                paragraphMenuSelectedItem = .code
            } else if element is QuoteNode {
                paragraphMenuSelectedItem = .quote
            } else {
                paragraphMenuSelectedItem = .paragraph
            }

            // Update links
            do {
                let selectedNode = try getSelectedNode(selection: selection)
                let selectedNodeParent = selectedNode.getParent()
                if selectedNode is LinkNode || selectedNodeParent is LinkNode {
                    linkButton?.isSelected = true
                } else {
                    linkButton?.isSelected = false
                }
            } catch {
                print("Error getting the selected Node: \(error.localizedDescription)")
            }
        }
    }

    private var imageMenuItems: [UIAction] {
        return [
            UIAction(title: "Insert Sample Image", image: UIImage(systemName: "photo"), handler: { [weak self] _ in
                self?.insertSampleImage()
            }),
            UIAction(title: "Insert Selectable Image", image: UIImage(systemName: "photo"), handler: { [weak self] _ in
                self?.insertSelectableImage()
            }),
        ]
    }
    
    private var embedMenuItems: [UIAction] {
        let twitterImage = UIImage(named: "twitter-icon")
        let resizedTwitterImage = twitterImage?.resized(to: CGSize(width: 20, height: 20))

        let instagramImage = UIImage(named: "instagram-icon")
        let resizedInstagramImage = instagramImage?.resized(to: CGSize(width: 20, height: 20))

        let youtubeImage = UIImage(named: "youtube-icon")
        let resizedYoutubeImage = youtubeImage?.resized(to: CGSize(width: 20, height: 20))

        return [
            UIAction(title: "Insert Twitter", image: resizedTwitterImage, handler: { [weak self] _ in
                self?.viewModel?.popupType = .twitterLink
                self?.viewModel?.didPressButton.toggle()
            }),
            UIAction(title: "Insert IG", image: resizedInstagramImage, handler: { [weak self] _ in
                self?.viewModel?.popupType = .instagramLink
                self?.viewModel?.didPressButton.toggle()
            }),
            UIAction(title: "Insert Youtube", image: resizedYoutubeImage, handler: { [weak self] _ in
                self?.viewModel?.popupType = .youtubeLink
                self?.viewModel?.didPressButton.toggle()
            }),
        ]
    }


    private func setBlock(creationFunc: () -> ElementNode) {
        try? editor?.update {
            if let selection = try getSelection() as? RangeSelection {
                setBlocksType(selection: selection, createElement: creationFunc)
            }
        }
    }

    private var imageMenu: UIMenu {
        return UIMenu(title: "Insert Image", image: nil, identifier: nil, options: [], children: imageMenuItems)
    }

    private var embeddedMenu: UIMenu {
        return UIMenu(title: "Insert Embed", image: nil, identifier: nil, options: [], children: embedMenuItems)
    }

    // MARK: - Button actions

    @objc func createHeading1Node(_: UIBarButtonItem) {
        setBlock {
            paragraphMenuSelectedItem == .h1 ? createParagraphNode() : createHeadingNode(headingTag: .h1)
            // Return nothing
        }
    }

    @objc func createHeading2Node(_: UIBarButtonItem) {
        setBlock {
            paragraphMenuSelectedItem == .h2 ? createParagraphNode() : createHeadingNode(headingTag: .h2)
            // Return nothing
        }
    }

    @objc func createQuoteNodeWrap(_: UIBarButtonItem) {
        setBlock {
            createQuoteNode()
            // Return nothing
        }
    }

    @objc private func toggleBold() {
        editor?.dispatchCommand(type: .formatText, payload: TextFormatType.bold)
    }

    @objc private func link() {
        // Handle link
    }

    private func insertSampleImage() {
        guard let url = Bundle.main.url(forResource: "lexical-logo", withExtension: "png") else {
            return
        }
        try? editor?.update {
            let imageNode = ImageNode(url: url.absoluteString, size: CGSize(width: 300, height: 300), sourceID: "")
            if let selection = try getSelection() {
                _ = try selection.insertNodes(nodes: [imageNode], selectStart: false)
            }
        }
    }

    private func insertSelectableImage() {
        guard let url = Bundle.main.url(forResource: "lexical-logo", withExtension: "png") else {
            return
        }
        try? editor?.update {
            let imageNode = SelectableImageNode(url: url.absoluteString, size: CGSize(width: 300, height: 300), sourceID: "")
            if let selection = try getSelection() {
                _ = try selection.insertNodes(nodes: [imageNode], selectStart: false)
            }
        }
    }

    func getSelectedNode(selection: RangeSelection) throws -> Node {
        let anchor = selection.anchor
        let focus = selection.focus

        let anchorNode = try selection.anchor.getNode()
        let focusNode = try selection.focus.getNode()

        if anchorNode == focusNode {
            return anchorNode
        }

        let isBackward = try selection.isBackward()
        if isBackward {
            return try focus.isAtNodeEnd() ? anchorNode : focusNode
        } else {
            return try anchor.isAtNodeEnd() ? focusNode : anchorNode
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
