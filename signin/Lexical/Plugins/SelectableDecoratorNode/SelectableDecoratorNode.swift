import Lexical
import UIKit

open class CustomSelectableDecoratorNode: DecoratorNode {

  // if you're using SelectableDecoratorNode, override `createContentView()` instead of `createView()`
  override public final func createView() -> UIView {
      print("CustomSelectableDecoratorNode createView")

      
    guard let editor = getActiveEditor() else {
      fatalError() // TODO: refactor decorator API to throws
    }
    let contentView = createContentView()
    let wrapper = CustomSelectableDecoratorView(frame: .zero)
    wrapper.contentView = contentView
    wrapper.editor = editor
    wrapper.nodeKey = getKey()
    try? wrapper.setUpListeners()
    return wrapper
  }

  // if you're using SelectableDecoratorNode, override `decorateContentView()` instead of `decorate()`
  override public final func decorate(view: UIView) {
      print("CustomSelectableDecoratorNode decorate")

    guard let view = view as? CustomSelectableDecoratorView, let contentView = view.contentView else {
      return // TODO: refactor decorator API to throws
    }
    decorateContentView(view: contentView, wrapper: view)
  }

  open func createContentView() -> UIView {
    fatalError("createContentView: base method not extended")
  }

  open func decorateContentView(view: UIView, wrapper: CustomSelectableDecoratorView) {
    fatalError("decorateContentView: base method not extended")
  }
}
