import UIKit

final class LinkifyLabel: UILabel {

    // MARK: Creating the Label

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        numberOfLines = 0
        isUserInteractionEnabled = true
    }

    convenience init(textAlignment alignment: NSTextAlignment = .left) {
        self.init(frame: .zero)
        self.textAlignment = alignment
    }

    private var linkRedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemRed]

    override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set {
            super.attributedText = {
                guard let newValue = newValue else { return nil }
                let text = NSMutableAttributedString(attributedString: newValue)

                text.enumerateAttribute(.linkRed, in: NSRange(location: 0, length: text.length), options: .longestEffectiveRangeNotRequired) { (value, subrange, _) in
                    guard let _ = value else { return }
                    text.addAttributes(linkRedAttributes, range: subrange)
                }

                return text
            }()
        }
    }

    // MARK: Finding Hyperlink Under Touch

    var didTapOnURL: (String) -> Void = {_ in}

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let url = self.url(at: touches) {
            didTapOnURL(url)
        }
        else {
            super.touchesEnded(touches, with: event)
        }
    }

    private func url(at touches: Set<UITouch>) -> String? {
        guard let attributedText = attributedText, attributedText.length > 0 else { return nil }
        guard let touchLocation = touches.sorted(by: { $0.timestamp < $1.timestamp } ).last?.location(in: self) else { return nil }
        guard let textStorage = preparedTextStorage() else { return nil }
        let layoutManager = textStorage.layoutManagers[0]
        let textContainer = layoutManager.textContainers[0]

        let characterIndex = layoutManager.characterIndex(for: touchLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        guard characterIndex >= 0, characterIndex != NSNotFound else { return nil }

        // Glyph index is the closest to the touch, therefore also validate if we actually tapped on the glyph rect
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: characterIndex, length: 1), actualCharacterRange: nil)
        let characterRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        guard characterRect.contains(touchLocation) else { return nil }

        // Custom link style
        if let url = textStorage.attribute(.linkRed, at: characterIndex, effectiveRange: nil) as? String {
            return url
        }

        return textStorage.attribute(.link, at: characterIndex, effectiveRange: nil) as? String
    }

    private func preparedTextStorage() -> NSTextStorage? {
        guard let attributedText = attributedText, attributedText.length > 0 else { return nil }

        // Creates and configures a text storage which matches with the UILabel's configuration.
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        let textStorage = NSTextStorage(string: "")
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineBreakMode = lineBreakMode
        textContainer.size = textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).size
        textStorage.setAttributedString(attributedText)

        return textStorage
    }
}


extension NSAttributedString.Key {
    static let linkRed = NSAttributedString.Key("linkRed")
}
