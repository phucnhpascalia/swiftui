import Lexical
import UIKit

public class CustomSelectableDecoratorView: UIView {
  public weak var editor: Editor?
  public var nodeKey: NodeKey?

  public var contentView: UIView? {
    didSet {
      if let oldValue, oldValue != contentView {
        oldValue.removeFromSuperview()
      }
      if let contentView {
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      }
    }
  }

  var updateListener: Editor.RemovalHandler?
  var gestureRecognizer: UITapGestureRecognizer?
  var borderView: UIView = UIView(frame: .zero)
  var rightButton: UIButton = UIButton(type: .system)

  internal func setUpListeners() throws {
    guard let editor, let nodeKey, gestureRecognizer == nil else {
      throw LexicalError.invariantViolation("expected editor and node key by now")
    }
    updateListener = editor.registerUpdateListener { [weak self] activeEditorState, previousEditorState, dirtyNodes in
      try? activeEditorState.read {
        let selection = try getSelection()
        if let selection = selection as? NodeSelection {
          let nodes = try selection.getNodes().map { node in
            node.getKey()
          }
          self?.setDrawsSelectionBorder(nodes.contains(nodeKey))
        } else {
          self?.setDrawsSelectionBorder(false)
        }
      }
    }

    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapReceived(sender:)))
    self.addGestureRecognizer(gestureRecognizer)
    self.gestureRecognizer = gestureRecognizer

    addSubview(borderView)
    borderView.frame = self.bounds
    borderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    borderView.isUserInteractionEnabled = false
    borderView.layer.borderColor = UIColor.red.cgColor
    borderView.layer.borderWidth = 2.0
    borderView.isHidden = true

      // Setup right button
      rightButton.setImage(UIImage(systemName: "xmark"), for: .normal)
      rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
      addSubview(rightButton)
      rightButton.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
          rightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
          rightButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
          rightButton.widthAnchor.constraint(equalToConstant: 40),
          rightButton.heightAnchor.constraint(equalToConstant: 40)
      ])
  }

  @objc private func tapReceived(sender: UITapGestureRecognizer) {
    if sender.state == .ended {
      try? editor?.update {
        var selection = try getSelection()
        if !(selection is NodeSelection) {
          let nodeSelection = NodeSelection(nodes: Set())
          getActiveEditorState()?.selection = nodeSelection
          selection = nodeSelection
        }
        guard let selection = selection as? NodeSelection, let nodeKey else {
          throw LexicalError.invariantViolation("Expected node selection by now")
        }
        selection.add(key: nodeKey)
      }
    }
  }

    @objc private func rightButtonTapped() {
        // Handle right button tap action here
        print("Right button tapped")
      }

  private var drawsSelectionBorder: Bool = false
  private func setDrawsSelectionBorder(_ isSelected: Bool) {
    self.drawsSelectionBorder = isSelected
    borderView.isHidden = !isSelected
  }

  deinit {
    if let updateListener {
      updateListener()
    }
  }
}

