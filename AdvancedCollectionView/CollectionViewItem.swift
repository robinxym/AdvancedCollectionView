//
//  CollectionViewItem.swift
//  AdvancedCollectionView
//
//  Created by Xue Yong Ming on 01/01/2017.
//  Copyright © 2017 Robin. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
      view.wantsLayer = true
      view.layer?.backgroundColor = NSColor.lightGray.cgColor

      // 1
      view.layer?.borderWidth = 0.0
      // 2
      view.layer?.borderColor = NSColor.white.cgColor
    }

  func setHighlight(selected: Bool) {
    view.layer?.borderWidth = selected ? 5.0 : 0.0
  }
}
