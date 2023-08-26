//
//  Extension.swift
//  
//
//  Created by Mahmudul Hasan on 2023-08-26.
//

import UIKit

extension LinkifyLabel {
    /// Creates and returns a LinkifyLabel
    /// - Parameters:
    ///   - alignment: alignment of your text. Default: .left
    ///   - inText: your label text
    ///   - links: Keys are words you'd like to highlight as link, values you'll get by tapping those links
    ///   - defaultStyle: settings false returns a red link, more in future
    ///   - onTap: callback function where you'll get the tapped value as defined in values
    /// - Returns: LinkifyLabel
    static func linkify(withAlignment alignment: NSTextAlignment = .left, inText: String, links: Dictionary<String, String>, defaultStyle: Bool = true, onTap: @escaping (String) -> Void) -> LinkifyLabel {
        let attributedString = NSMutableAttributedString(string: inText)

        links.forEach({ link in
            let linkAttribute: NSAttributedString.Key = defaultStyle ? .link : .linkRed
            let attributes: [NSAttributedString.Key: Any] = [
                linkAttribute: link.value
            ]
            let urlAttributedString = NSAttributedString(string: link.key, attributes: attributes)

            let range = (attributedString.string as NSString).range(of: link.key)

            attributedString.replaceCharacters(in: range, with: urlAttributedString)

        })

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        let label = LinkifyLabel()
        label.attributedText = attributedString
        label.translatesAutoresizingMaskIntoConstraints = false
        label.didTapOnURL = onTap

        return label

    }


    /// Creates and returns a LinkifyLabel
    /// - Parameters:
    ///   - alignment: alignment of your text. Default: .left
    ///   - inText: your label text
    ///   - linkWords: words you'd like to highlight as link
    ///   - values: values you'll get by tapping those links
    ///   - defaultStyle: settings false returns a red link, more in future
    ///   - onTap: callback function where you'll get the tapped value as defined in values
    /// - Returns: LinkifyLabel
    static func linkify(withAlignment alignment: NSTextAlignment = .left, inText: String, linkWords: [String], values: [String], defaultStyle: Bool = true, onTap: @escaping (String) -> Void) -> LinkifyLabel {
        // we want a pair for each
        assert(linkWords.count == values.count, "linkWords and values must be equal in count. You have \(linkWords.count) linkWords and \(values.count) values")
        let attributedString = NSMutableAttributedString(string: inText)

        // since link item and values are equal in length we can just iterate over one items length
        for index in 0..<linkWords.count {
            // the linked word that user sees
            let linkText = linkWords[index]
            // the linked value
            let linkValue = values[index]
            // if our main string doesn't contain this value we'll skip
            if !inText.contains(linkText) { continue }

            let linkAttribute: NSAttributedString.Key = defaultStyle ? .link : .linkRed

            let attributes: [NSAttributedString.Key: Any] = [
                linkAttribute: linkValue
            ]

            let urlAttributedString = NSAttributedString(string: linkText, attributes: attributes)

            let range = (attributedString.string as NSString).range(of: linkText)

            attributedString.replaceCharacters(in: range, with: urlAttributedString)
        }


        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        let label = LinkifyLabel()
        label.attributedText = attributedString
        label.translatesAutoresizingMaskIntoConstraints = false
        label.didTapOnURL = onTap

        return label
    }
}

