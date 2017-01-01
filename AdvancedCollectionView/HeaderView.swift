//
//  HeaderView.swift
//  AdvancedCollectionView
//
//  Created by Xue Yong Ming on 01/01/2017.
//  Copyright © 2017 Robin. All rights reserved.
//

import Cocoa

class HeaderView: NSView {
  @IBOutlet weak var sectionTitle: NSTextField!
  @IBOutlet weak var imageCount: NSTextField!

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    // Drawing code here.
    NSColor(calibratedWhite: 0.8 , alpha: 0.8).set()
    NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.sourceOver)
  }

}
