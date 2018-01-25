import Cocoa

extension NSView {
    public func addTextField(stringValue: String,
                      fontName: String = "Courier",
                      fontSize: CGFloat = 160.0,
                      alphaValue: CGFloat) {
        let textField = NSTextField(frame: bounds)
        textField.stringValue = stringValue
        textField.font = NSFont(name: fontName, size: fontSize)
        textField.alphaValue = alphaValue

        addSubview(textField)
    }
}
