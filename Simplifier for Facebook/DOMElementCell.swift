//
//  DOMElementCell.swift
//  Simplifier for Facebook
//
//  Created by Patrick Botros on 4/23/20.
//  Copyright © 2020 Patrick Botros. All rights reserved.
//

import Cocoa

protocol CheckBox: class {
    func checkBox(blocked: Bool, index: Int)
    func updateBlockListJSON()
}

class DOMElementCell: NSTableRowView {
    var rowNumber: Int?
    weak var delegate: CheckBox?
    var blockableElements: [BlockableElement]?

    @IBAction func checkBoxClicked(_ sender: Any) {
        let name = blockableElements![rowNumber!].elementName
        if blockableElements![rowNumber!].blocked {
            delegate?.checkBox(blocked: false, index: rowNumber!)
            defaults.set(false, forKey: name)
            delegate?.updateBlockListJSON()
        } else {
            delegate?.checkBox(blocked: true, index: rowNumber!)
            defaults.set(true, forKey: name)
            delegate?.updateBlockListJSON()
        }
    }
    @IBOutlet weak var checkBoxImage: NSButton!
    @IBOutlet weak var elementNameLabel: NSTextFieldCell!
}

