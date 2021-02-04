//
//  ViewController.swift
//  Simplifier for Facebook
//
//  Created by Patrick Botros on 4/23/20.
//  Copyright © 2020 Patrick Botros. All rights reserved
//

import Cocoa
import SafariServices

let defaults = UserDefaults.standard
let appGroupID: String = "L27L4K8SQU.shockerella.Simplifier-for-Facebook"
let contentBlockerID: String = "shockerella.Simplifier-for-Facebook.Content-Blocker"

typealias SwiftyJSON = [SwiftyRule]

class BlockableElement {
    let elementName: String
    let rules: [BlockerRule]
    var blocked: Bool
    init(withName name: String, andRules rules: [BlockerRule], isBlockedByDefault blocked: Bool) {
        self.elementName = name
        self.rules = rules
        self.blocked = blocked
    }
    convenience init(withName name: String, andRule rule: BlockerRule, isBlockedByDefault blocked: Bool) {
        self.init(withName: name, andRules: [rule], isBlockedByDefault: blocked)
    }
}

// Manually ensure these default block properties match the defaultBlockList.json.

var blockableElements: [BlockableElement] = [
    
    BlockableElement(withName: "Newsfeed", andRules: [
        BlockerRule(selector: "div.pedkr2u6.tn0ko95a.pnx7fd3z"),
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href$='www.facebook.com/?sk=h_chr']")
    ], isBlockedByDefault: false),
    
    BlockableElement(withName: "Stories", andRule: BlockerRule(selector: "div.d2edcug0.e3xpq0al"), isBlockedByDefault: false),

    BlockableElement(withName: "Create Post", andRule: BlockerRule(selector: "div.tr9rh885.k4urcfbm div.sjgh65i0 div.j83agx80.k4urcfbm.l9j0dhe7 div[aria-label='Create a post']"), isBlockedByDefault: false),

    BlockableElement(withName: "Rooms", andRule: BlockerRule(selector: "div[data-pagelet='VideoChatHomeUnit']"), isBlockedByDefault: true),

    BlockableElement(withName: "Friends", andRules: [
        BlockerRule(selector: "li.buofh1pr a[href='/friends/']"),
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href$='/friends/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/friends/.*"], actionType: .block)
    ], isBlockedByDefault: false),
    
    BlockableElement(withName: "Watch", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href$='facebook.com/watch/']"),
        BlockerRule(selector: "li.buofh1pr.to382e16.o5zgeu5y.jrc8bbd0.dawyy4b1.h676nmdw.hw7htvoc a[href='/watch/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/watch.*"], actionType: .block)
    ], isBlockedByDefault: false),

    BlockableElement(withName: "Marketplace", andRules: [
        BlockerRule(selector: "li a[href$='/marketplace/?ref=bookmark']"),
        BlockerRule(selector: "li.buofh1pr.to382e16.o5zgeu5y.jrc8bbd0.dawyy4b1.h676nmdw.hw7htvoc a[href='/marketplace/?ref=app_tab']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/marketplace.*"], actionType: .block)
    ], isBlockedByDefault: true),

    BlockableElement(withName: "Groups", andRules: [
        BlockerRule(selector: "li a[href$='/groups/?ref=bookmarks']"),
        BlockerRule(selector: "li.buofh1pr.h676nmdw a[href*='/groups/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/groups.*"], actionType: .block)
    ], isBlockedByDefault: true),

    BlockableElement(withName: "Messenger", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href$='www.facebook.com/messages/t/']"),
        BlockerRule(selector: "div.bp9cbjyn.j83agx80.datstx6m div[aria-label='Messenger']")
    ], isBlockedByDefault: false),

    BlockableElement(withName: "Right Sidebar", andRule: BlockerRule(selector: "div[data-pagelet='RightRail']"), isBlockedByDefault: false),
    
    BlockableElement(withName: "Left Sidebar", andRule: BlockerRule(selector: "div[data-pagelet='LeftRail']"), isBlockedByDefault: false),
    
    BlockableElement(withName: "Legal Footer", andRule: BlockerRule(selector: "footer[role='contentinfo']"), isBlockedByDefault: true),

    BlockableElement(withName: "Events", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='www.facebook.com/events']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/events/.*"], actionType: .block)
    ], isBlockedByDefault: true),

    BlockableElement(withName: "Pages", andRule: BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='facebook.com/pages/']"), isBlockedByDefault: true),

    BlockableElement(withName: "Memories", andRule: BlockerRule(selector: "a[href$='/memories/?source=bookmark']"), isBlockedByDefault: true),

    BlockableElement(withName: "Jobs", andRules: [
        BlockerRule(selector: "a[href$='facebook.com/jobs/?source=bookmark']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/jobs.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Oculus", andRules: [
        BlockerRule(selector: "a[href='https://www.facebook.com/270208243080697/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/Oculusvr/"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Blood Donations", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='www.facebook.com/blooddonations/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/blooddonations/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Ads", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='www.facebook.com/ads/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/ads/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Campus", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href$='www.facebook.com/campus/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/campus/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Community Help", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href='/community_help/?page_source=facebook_bookmark']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/community_help/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Facebook Pay", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='secure.facebook.com/facebook_pay/']"),
        BlockerRule(triggers: [.urlFilter: "https?://secure.facebook.com/facebook_pay/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Weather", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='www.facebook.com/weather/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/weather/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "COVID-19 Information Center", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href='https://www.facebook.com/coronavirus_info/?page_source=bookmark']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/coronavirus_info/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Favorites", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href='https://www.facebook.com/?sk=favorites']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/?sk=favorites"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Friend Lists", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href='https://www.facebook.com/bookmarks/lists/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/bookmarks/lists/"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Fundraisers", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href='https://www.facebook.com/fundraisers/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/fundraisers/.*"], actionType: .block),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/donate/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Climate Science Information Center", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='www.facebook.com/climatescienceinfo/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/climatescienceinfo/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Games", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='www.facebook.com/games/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/games/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Gaming Video", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='www.facebook.com/gaming/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/gaming/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Lift Black Voices", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href$='/liftblackvoices/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/liftblackvoices/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Live", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href$='www.facebook.com/watch/live/?ref=live_bookmark']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/watch/live/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Messenger Kids", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href$='www.facebook.com/messenger_kids/?referrer=bookmark']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/messenger_kids/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Most Recent", andRule: BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href$='www.facebook.com/?sk=h_chr']"), isBlockedByDefault: true),
    
    BlockableElement(withName: "Movies", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='www.facebook.com/movies/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/messenger_kids/.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Offers", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href$='/wallet']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/offers/v2/wallet.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Saved", andRule: BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='facebook.com/saved/']"), isBlockedByDefault: true),
    
    BlockableElement(withName: "Town Hall", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href$='/townhall/?ref=bookmarks']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/townhall.*"], actionType: .block)
    ], isBlockedByDefault: true),
    
    BlockableElement(withName: "Voting Information Center", andRules: [
        BlockerRule(selector: "div[data-pagelet='LeftRail'] a[href*='/votinginformationcenter/']"),
        BlockerRule(triggers: [.urlFilter: "https?://www.facebook.com/votinginformationcenter.*"], actionType: .block)
    ], isBlockedByDefault: true)
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
            for rule in blockableElements[elementIndex].rules {
                activeBlockingRules.append(rule.asSwiftyRule())
            }
        }
        tableView.reloadData()
    }

    func updateBlockListJSON() {

        let blockListJSON = try? JSONSerialization.data(withJSONObject: activeBlockingRules, options: .prettyPrinted)

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
        if let cell = tableView.makeView(withIdentifier: domElementReuseID, owner: nil) as? ChecklistRow {
            cell.elementName = blockableElements[row].elementName
            if blockableElements[row].blocked {
                cell.setAccessibilityLabel("Checked checkbox for  \(cell.elementName ?? "element")")
                cell.checkBoxImage.image = NSImage(named: "checked")
            } else {
                cell.setAccessibilityLabel("Unchecked checkbox for  \(cell.elementName ?? "element")")
                cell.checkBoxImage.image = NSImage(named: "unchecked")
            }
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
