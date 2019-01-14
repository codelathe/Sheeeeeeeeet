//
//  ActionSheetDangerButton.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2017-11-27.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

/*
 
 Danger buttons have no special behavior, but can be used to
 indicate that the effect of the action sheet is destructive.
 They are basically just OK buttons with a "red alert" style.
 
 The value of a danger button is `ButtonType.ok`.
 
 */

import UIKit

open class ActionSheetDangerButton: ActionSheetOkButton {
    
    
    // MARK: - Functions
    
    open override func cell(for tableView: UITableView) -> UITableViewCell {
        return ActionSheetDangerButtonCell(style: cellStyle, reuseIdentifier: cellReuseIdentifier)
    }
    
    
    // MARK: - Deprecated
    
    @available(*, deprecated, message: "applyAppearance will be removed in 1.4.0. Use the new appearance model instead.")
    open override func applyAppearance(_ appearance: ActionSheetAppearance) {
        self.appearance = customAppearance ?? ActionSheetDangerButtonAppearance(copy: appearance.dangerButton)
    }
}
