//
//  ViewController.swift
//  AdvancedCollectionView
//
//  Created by Xue Yong Ming on 01/01/2017.
//  Copyright © 2017 Robin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  @IBOutlet weak var collectionView: NSCollectionView!
  @IBOutlet weak var showSectionButton: NSButton!
  @IBOutlet weak var addButton: NSButton!
  @IBOutlet weak var removeButton: NSButton!

  var fileURLs: [[URL]] = [[]]
  var indexPathsOfItemsBeingDragged: Set<IndexPath>!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    fileURLs[0] = getFileURLs()
    configCollectionView()
//    collectionView.reloadData()
    registerForDragAndDrop()
  }

  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }

  private func configCollectionView() {
//    let flowLayout = NSCollectionViewFlowLayout()
    let flowLayout = StickyHeadersLayout()
    flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
//    flowLayout.sectionInset = EdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
    flowLayout.sectionInset = EdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0)
    flowLayout.minimumLineSpacing = 10.0
    flowLayout.minimumInteritemSpacing = 10.0
    collectionView.collectionViewLayout = flowLayout

    view.wantsLayer = true

//    collectionView.layer?.backgroundColor = NSColor.black.cgColor
  }

  private func getFileURLs() -> [URL] {
    let manager = FileManager.default
    let desktopURL = try! manager.url(for: .desktopDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
    let fileURLs = try! manager.contentsOfDirectory(at: desktopURL, includingPropertiesForKeys: [URLResourceKey.pathKey], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
    //    let fileNames = fileURLs.map{ $0.path }
    return fileURLs
  }

  @IBAction func showHideSections(sender: AnyObject) {
    fileURLs = [[]]
    fileURLs[0] = getFileURLs()
    if (sender as! NSButton).state == NSOnState {
      fileURLs.append(getFileURLs())
      fileURLs.append(getFileURLs())
    }

    // 3
    collectionView.reloadData()
  }

  func highlightItems(selected: Bool, indexPaths: Set<IndexPath>) {
    indexPaths.forEach { (indexPath) in
      guard let item = collectionView.item(at: indexPath) as? CollectionViewItem else { return }
      item.setHighlight(selected: selected)
    }

    addButton.isEnabled = collectionView.selectionIndexPaths.count == 1
    removeButton.isEnabled = !collectionView.selectionIndexPaths.isEmpty
  }

  private func insertAtIndexPathFromURLs(urls: [URL], atIndexPath: IndexPath) {
    let section = atIndexPath.section
    let currentItem = atIndexPath.item

    let subArray1 = fileURLs[section][fileURLs[section].startIndex..<currentItem]
    let subArray2 = fileURLs[section][currentItem..<fileURLs[section].endIndex]
    fileURLs[section] = subArray1 + urls + subArray2
//    fileURLs[section] = Array(fileURLs[section][fileURLs[section].startIndex..<currentItem]) + urls + Array(fileURLs[section][currentItem..<fileURLs[section].endIndex])
    collectionView.insertItems(at: Set([atIndexPath]))
  }

  @IBAction func addImage(sender: NSButton) {
    // 4
    let insertAtIndexPath = collectionView.selectionIndexPaths.first!
    //5
    let openPanel = NSOpenPanel()
    openPanel.canChooseDirectories = false
    openPanel.canChooseFiles = true
    openPanel.allowsMultipleSelection = true
    openPanel.allowedFileTypes = ["public.image"]
    openPanel.beginSheetModal(for: view.window!) { (response) -> Void in
      guard response == NSFileHandlingPanelOKButton else {return}
      self.insertAtIndexPathFromURLs(urls: openPanel.urls, atIndexPath: insertAtIndexPath)
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }

  @IBAction func removeImage(sender: NSButton) {
    let selectionIndexPaths = collectionView.selectionIndexPaths
    guard !selectionIndexPaths.isEmpty else {return}

//    let sortedSelectionIndexPaths = selectionIndexPaths.sorted { (indexPath0, indexPath1) -> Bool in
//      if indexPath0.section != indexPath1.section {return indexPath0.section > indexPath1.section}
//      else {return indexPath0.item > indexPath1.item}
//    }
    let sortedSelectionIndexPaths = selectionIndexPaths.sorted {(indexPath0, indexPath1) -> Bool in
      indexPath0.compare(indexPath1) == .orderedDescending
    }

    sortedSelectionIndexPaths.forEach { (indexPath) in
      fileURLs[indexPath.section].remove(at: indexPath.item)
    }

//    collectionView.reloadData()
    NSAnimationContext.current().duration = 1.0
    collectionView.animator().deleteItems(at: selectionIndexPaths)
    collectionView.reloadSections(IndexSet(sortedSelectionIndexPaths.map{$0.section}))
  }

  func registerForDragAndDrop() {
    collectionView.register(forDraggedTypes: [NSURLPboardType])
    collectionView.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: true)
    collectionView.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: false)
  }
}

extension ViewController: NSCollectionViewDataSource {
  func numberOfSections(in collectionView: NSCollectionView) -> Int {
    return fileURLs.count
  }

  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return fileURLs[section].count
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let item = collectionView.makeItem(withIdentifier: "CollectionViewItem", for: indexPath)
    guard let collectionViewItem = item as? CollectionViewItem else {return item}

    let fileURL = fileURLs[indexPath.section][indexPath.item]
    let image = NSImage(contentsOf: fileURL)
    collectionViewItem.imageView?.image = image
    collectionViewItem.textField?.stringValue = fileURL.lastPathComponent

    if let selectedIndexPath = collectionView.selectionIndexPaths.first, selectedIndexPath == indexPath {
      collectionViewItem.setHighlight(selected: true)
    } else {
      collectionViewItem.setHighlight(selected: false)
    }

    return item
  }

  func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
    let identifier: String = kind == NSCollectionElementKindSectionHeader ? "HeaderView" : ""
    let view = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: identifier, for: indexPath)
    // 2
    if kind == NSCollectionElementKindSectionHeader {
      let headerView = view as! HeaderView
      headerView.sectionTitle.stringValue = "Section \(indexPath.section)"
      let numberOfItemsInSection = fileURLs[indexPath.section].count
      headerView.imageCount.stringValue = "\(numberOfItemsInSection) image files"
    }
    return view
  }
}

extension ViewController : NSCollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
    return showSectionButton.state == NSOffState ? NSZeroSize : NSSize(width: 1000, height: 40)
  }
}

extension ViewController : NSCollectionViewDelegate {
  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
//    guard let indexPath = indexPaths.first else { return }
//    guard let item = collectionView.item(at: indexPath) else { return }
//    (item as! CollectionViewItem).setHighlight(selected: true)
    highlightItems(selected: true, indexPaths: indexPaths)
  }

  func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
//    guard let indexPath = indexPaths.first else { return }
//    guard let item = collectionView.item(at: indexPath) else { return }
//    (item as! CollectionViewItem).setHighlight(selected: false)
    highlightItems(selected: false, indexPaths: indexPaths)
  }

  func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexes: IndexSet, with event: NSEvent) -> Bool {
    return true
  }

  func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
    return fileURLs[indexPath.section][indexPath.item] as NSPasteboardWriting?
  }

  func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
     indexPathsOfItemsBeingDragged = indexPaths
  }

  func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
    if proposedDropOperation.pointee == NSCollectionViewDropOperation.on {
      proposedDropOperation.pointee = NSCollectionViewDropOperation.before
    }

    if indexPathsOfItemsBeingDragged == nil {
      return NSDragOperation.copy
    } else {
      let sectionOfItemBeingDragged = indexPathsOfItemsBeingDragged.first!.section
      // 1
      if sectionOfItemBeingDragged == proposedDropIndexPath.pointee.section && indexPathsOfItemsBeingDragged.count == 1 {
        return NSDragOperation.move
      } else {
        return []
      }
    }
  }

  func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
    if indexPathsOfItemsBeingDragged != nil {
      let indexPathOfFirstItemBeingDragged = indexPathsOfItemsBeingDragged.first!
      var toIndexPath = indexPath
      if indexPathOfFirstItemBeingDragged.compare(indexPath) == .orderedAscending {
        toIndexPath.item -= 1
      }
      let fileURL = fileURLs[indexPathOfFirstItemBeingDragged.section][indexPathOfFirstItemBeingDragged.item]
      fileURLs[indexPathOfFirstItemBeingDragged.section].remove(at: indexPathOfFirstItemBeingDragged.item)
      fileURLs[toIndexPath.section].insert(fileURL, at: toIndexPath.item)

      collectionView.moveItem(at: indexPathOfFirstItemBeingDragged, to: toIndexPath)
    }else {
      var droppedObjects = [URL]()
      draggingInfo.enumerateDraggingItems(options: .concurrent, for: collectionView, classes: [URL.self as! AnyObject.Type], searchOptions: [NSPasteboardURLReadingFileURLsOnlyKey : NSNumber(value: true)], using: { (draggingItem, index, stop) in
        if let url = draggingItem.item as? URL {
          droppedObjects.append(url)
        }
      })

      let subArray1 = fileURLs[indexPath.section][fileURLs[indexPath.section].startIndex..<indexPath.item]
      let subArray2 = fileURLs[indexPath.section][indexPath.item..<fileURLs[indexPath.section].endIndex]
      fileURLs[indexPath.section] = subArray1 + droppedObjects + subArray2
      collectionView.insertItems(at: Set([indexPath]))
    }

    return true
  }

  func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
    indexPathsOfItemsBeingDragged = nil
  }
}
