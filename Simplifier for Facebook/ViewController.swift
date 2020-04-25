//
//  ViewController.swift
//  Simplifier for Facebook
//
//  Created by Patrick Botros on 4/23/20.
//  Copyright © 2020 Patrick Botros. All rights reserved.
//

import Cocoa
import SafariServices

let defaults = UserDefaults.standard
let appGroupID: String = "L27L4K8SQU.shockerella.Simplifier-for-Facebook"
let contentBlockerID: String = "shockerella.Simplifier-for-Facebook.Content-Blocker"

typealias SwiftyJSON = [[String: [String: Any]]]

class BlockableElement {
    var elementName: String = ""
    var blocked: Bool = false
    var selector: String = ""
    convenience init(name: String, blocked: Bool, selector: String) {
        self.init()
        self.elementName = name
        self.selector = selector
        self.blocked = blocked
    }
}

// Manually ensure these default values match the defaultBlockList.json.
var blockableElements: [BlockableElement] = [
     BlockableElement(name: "Marketplace", blocked: true, selector: "a[data-testid='left_nav_item_Marketplace']"),
     BlockableElement(name: "Shortcuts", blocked: true, selector: "#pinnedNav.homeSideNav"),
     BlockableElement(name: "Explore", blocked: true, selector: "#appsNav.homeSideNav"),
     BlockableElement(name: "Stories", blocked: false, selector: "#stories_pagelet_below_composer"),
     BlockableElement(name: "Languages & Legal Footer", blocked: true, selector: "#pagelet_rhc_footer")
]

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, CheckBox {

    @IBOutlet weak var tableView: NSTableView!

    @IBAction func openSafariExtensionPreferences(_ sender: Any) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: contentBlockerID)
    }

    var commaSeparatedSelectorsToBlock: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // reload with user's custom block preferences.
        for blockListitem in blockableElements where defaults.object(forKey: blockListitem.elementName) != nil {
            blockListitem.blocked = defaults.bool(forKey: blockListitem.elementName)
        }
        tableView.reloadData()
    }

    func checkBox(blocked: Bool, index: Int) {
        blockableElements[index].blocked = blocked
        var selectorsToBlock: [String] = []
        for elementIndex in 0...blockableElements.count-1 where blockableElements[elementIndex].blocked {
            selectorsToBlock.append(blockableElements[elementIndex].selector)
            commaSeparatedSelectorsToBlock = selectorsToBlock.joined(separator: ", ")
        }
        tableView.reloadData()
    }

    func updateBlockListJSON() {

        let blockList: SwiftyJSON =
            [
                [
                    "trigger": [
                        "url-filter": "https://www.facebook.com.*"
                    ],
                    "action": [
                        "type": "css-display-none",
                        "selector": commaSeparatedSelectorsToBlock
                    ]
                ]
            ]

        let blockListJSON = try? JSONSerialization.data(withJSONObject: blockList)

        let appGroupPathname = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!

        let blockListJSONfileLocation = appGroupPathname.appendingPathComponent("blockList.json")

        try? blockListJSON!.write(to: blockListJSONfileLocation)

        SFContentBlockerManager.reloadContentBlocker(withIdentifier: contentBlockerID, completionHandler: { error in
            print(error ?? "🔄 Blocker reload success.")
        })
    }
}

// Basic tableView set up functions.
extension ViewController {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return blockableElements.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let domElementReuseID = NSUserInterfaceItemIdentifier(rawValue: "domElementIdentifier")
        if let cell = tableView.makeView(withIdentifier: domElementReuseID, owner: nil) as? DOMElementCell {
            cell.elementNameLabel?.stringValue = blockableElements[row].elementName
            if blockableElements[row].blocked {
                cell.checkBoxImage.image = NSImage(named: "checked")
            } else {
                cell.checkBoxImage.image = NSImage(named: "unchecked")
            }

            // here we assign the cell's properties which can be used in the DomElementCell methods.
            cell.delegate = self
            cell.rowNumber = row
            cell.blockableElements = blockableElements

            return cell
        }
        return nil
    }
}

// aesthetics 👨🏻‍🎨
class ColoredView: NSView {
    override func updateLayer() {
        self.layer?.backgroundColor = NSColor(named: "background_color")?.cgColor
    }
}

// aesthetics 👨🏻‍🎨
extension ViewController {
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.isMovableByWindowBackground = true
        tableView.rowHeight = 33
        tableView.headerView = nil
        tableView.selectionHighlightStyle = .none
    }
}
