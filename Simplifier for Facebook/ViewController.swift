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

typealias SwiftyJSON = [SwiftyRule]

class BlockableElement {
    let elementName: String
    let rule: BlockerRule
    var blocked: Bool
    init(withName name: String, andRule rule: BlockerRule, isBlockedByDefault blocked: Bool) {
        self.elementName = name
        self.rule = rule
        self.blocked = blocked
    }
}

// Manually ensure these default block properties match the defaultBlockList.json.
var blockableElements: [BlockableElement] = [
    BlockableElement(withName: "Marketplace", andRule: BlockerRule(selector: "a[data-testid='left_nav_item_Marketplace']"), isBlockedByDefault: true),
    BlockableElement(withName: "Shortcuts", andRule: BlockerRule(selector: "a[data-testid='left_nav_item_Marketplace']"), isBlockedByDefault: true),
    BlockableElement(withName: "Explore", andRule: BlockerRule(selector: "#appsNav.homeSideNav"), isBlockedByDefault: true),
    BlockableElement(withName: "Stories", andRule: BlockerRule(selector: "#stories_pagelet_below_composer"), isBlockedByDefault: false),
    BlockableElement(withName: "Languages & Legal Footer", andRule: BlockerRule(selector: "#pagelet_rhc_footer"), isBlockedByDefault: true)
]

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, DOMElementCellDelegate {

    @IBOutlet weak var tableView: NSTableView!

    @IBAction func openIssuePage(_ sender: Any) {
        NSWorkspace.shared.open(NSURL(string: "https://github.com/patrickshox/Simplifier-for-Facebook/issues")! as URL)
    }

    @IBAction func openSafariExtensionPreferences(_ sender: Any) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: contentBlockerID)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // reload with user's custom block preferences.
        for blockListitem in blockableElements where defaults.object(forKey: blockListitem.elementName) != nil {
            blockListitem.blocked = defaults.bool(forKey: blockListitem.elementName)
        }
        tableView.reloadData()
    }

    var activeBlockingRules = [SwiftyRule]()

    func updateDataSource(blocked: Bool, index: Int) {
        blockableElements[index].blocked = blocked
        activeBlockingRules = [SwiftyRule]()
        for elementIndex in 0...blockableElements.count-1 where blockableElements[elementIndex].blocked {
            activeBlockingRules.append(blockableElements[elementIndex].rule.asSwiftyRule())
        }
        tableView.reloadData()
    }

    func updateBlockListJSON() {

        var blockList = [Any]()

        for activeRule in activeBlockingRules {
            blockList.append(activeRule)
        }

        print(blockList)

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
        if let cell = tableView.makeView(withIdentifier: domElementReuseID, owner: nil) as? BlockableElementRow {
            if blockableElements[row].blocked {
                cell.checkBoxImage.image = NSImage(named: "checked")
            } else {
                cell.checkBoxImage.image = NSImage(named: "unchecked")
            }
            cell.elementName = blockableElements[row].elementName
            cell.elementNameLabel?.stringValue = blockableElements[row].elementName
            cell.containingViewController = self
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
