//
//  UIStackView+.swift
//  Successes
//
//  Created by Jared Lindsay on 2/14/21.
//

import UIKit

extension UIStackView {
  
  /// Removes all arranged subviews from the stack.
  func removeAllArrangedSubviews() {
    for subview in arrangedSubviews {
      self.removeArrangedSubview(subview)
    }
  }
  
}
