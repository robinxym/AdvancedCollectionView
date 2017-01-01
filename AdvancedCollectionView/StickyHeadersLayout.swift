//
//  StickyHeadersLayout.swift
//  AdvancedCollectionView
//
//  Created by Xue Yong Ming on 01/01/2017.
//  Copyright © 2017 Robin. All rights reserved.
//

import Cocoa

class StickyHeadersLayout: NSCollectionViewFlowLayout {
  override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
    var layoutAttributes = super.layoutAttributesForElements(in: rect)

    let sectionsToMoveHeaders = NSMutableIndexSet()
    for attributes in layoutAttributes {
      if attributes.representedElementCategory == .item {
        sectionsToMoveHeaders.add(attributes.indexPath!.section)
      }
    }

    for attributes in layoutAttributes {
      if let elementKind = attributes.representedElementKind, elementKind == NSCollectionElementKindSectionHeader {
        sectionsToMoveHeaders.remove(attributes.indexPath!.section)
      }
    }

    sectionsToMoveHeaders.enumerate(using: { (index, stop) -> Void in
      let indexPath = NSIndexPath(forItem: 0, inSection: index)
      let attributes = self.layoutAttributesForSupplementaryView(ofKind: NSCollectionElementKindSectionHeader, at: indexPath as IndexPath)
      if attributes != nil {
        layoutAttributes.append(attributes!)
      }
    })

    for attributes in layoutAttributes {
      if let elementKind = attributes.representedElementKind, elementKind == NSCollectionElementKindSectionHeader {
        let section = attributes.indexPath!.section
        let attributesForFirstItemInSection = layoutAttributesForItem(at: NSIndexPath(forItem: 0, inSection: section) as IndexPath)
        let attributesForLastItemInSection = layoutAttributesForItem(at: NSIndexPath(forItem: collectionView!.numberOfItems(inSection: section) - 1, inSection: section) as IndexPath)
        var frame = attributes.frame

        let offset = collectionView!.enclosingScrollView?.documentVisibleRect.origin.y
        let minY = attributesForFirstItemInSection!.frame.minY - frame.height
        let maxY = attributesForLastItemInSection!.frame.maxY - frame.height
        let y = min(max(offset!, minY), maxY)
        frame.origin.y = y
        attributes.frame = frame

        attributes.zIndex = 99
      }
    }
    
    return layoutAttributes
  }

  override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
    return true
  }
}
