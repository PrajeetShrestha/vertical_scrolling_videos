//
//  UIView+NSConstraints.swift
//  DemoVerticalScroll
//
//  Created by Prajeet Shrestha on 12/06/2025.
//

import UIKit
import Foundation

extension UIView {
    func pinToEdges(of superview: UIView, with insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }
}

extension UIView {
    func centerInSuperview(leadingInset: CGFloat = 0, trailingInset: CGFloat = 0) {
        guard let superview = superview else { return }
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leadingInset),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -trailingInset)
        ])
    }
}
