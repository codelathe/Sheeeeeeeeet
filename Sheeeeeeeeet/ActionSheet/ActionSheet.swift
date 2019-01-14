//
//  ActionSheet.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2017-11-26.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

/*
 
 This is the main class in the Sheeeeeeeeet library. You can
 use it to create action sheets and present them in any view
 controller, from any source view or bar button item.
 
 
 ## Creating action sheet instances
 
 You create instances of this class by providing `init(...)`
 with the items to present and an action to call whenever an
 item is selected. If you must have an action sheet instance
 before you can setup its items (this may happen when you're
 subclassing), you can setup the items afterwards by calling
 the `setup(items:)` function.
 
 
 ## Subclassing
 
 This class can be subclassed, which is a good practice when
 you want to use your own models in a controlled way. If you
 have a podcast app, you could have a `SleepTimerActionSheet`
 that automatically sets up its `SleepTimerTime` options and
 streamlines how you work with a sleep timer. This is a good
 way to setup the base action sheet for specific use cases.
 
 
 ## Presentation
 
 You can inject a custom presenter if you want to change how
 the sheet is presented and dismissed. The default presenter
 for iPhone devices is `ActionSheetStandardPresenter`, while
 iPad devices most often get an `ActionSheetPopoverPresenter`.
 
 
 ## Handling item selections
 
 The `selectAction` is triggered when a user taps an item in
 the action sheet. It provides you with the action sheet and
 the selected item. It is very important to use `[weak self]`
 in this block, to avoid memory leaks.
 
 
 ## Handling item taps
 
 Action sheets receive a call to `handleTap(on:)` every time
 an item is tapped. You can override it if you, for instance,
 want to perform any animations before calling `super`.
 
 */

import UIKit

open class ActionSheet: UIViewController {
    
    
    // MARK: - Deprecated Members
    
    @available(*, deprecated, message: "appearance will be removed in 1.4.0. Use the new appearance model instead")
    public var appearance = ActionSheetAppearance(copy: .standard)
    
    @available(*, deprecated, message: "setupItemsAndButtons(with:) will be removed in 1.4.0. Use `setup(items:)` instead")
    open func setupItemsAndButtons(with items: [ActionSheetItem]) { setup(items: items) }
    
    @available(*, deprecated, message: "itemSelectAction will be removed in 1.4.0. Use `selectAction` instead")
    open var itemSelectAction: SelectAction { return selectAction }
    
    
    // MARK: - Initialization
    
    public init(
        items: [ActionSheetItem] = [],
        presenter: ActionSheetPresenter = ActionSheet.defaultPresenter,
        action: @escaping SelectAction) {
        self.presenter = presenter
        selectAction = action
        super.init(nibName: ActionSheet.className, bundle: ActionSheet.bundle)
        setup(items: items)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        presenter = ActionSheet.defaultPresenter
        selectAction = { _, _ in print("itemSelectAction is not set") }
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Setup
    
    open func setup() {
        preferredContentSize.width = preferredPopoverWidth
    }
    
    open func setup(items: [ActionSheetItem]) {
        self.items = items.filter { !($0 is ActionSheetButton) }
        buttons = items.compactMap { $0 as? ActionSheetButton }
        reloadData()
    }
    
    
    // MARK: - View Controller Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setup(itemsTableView, with: itemHandler)
        setup(buttonsTableView, with: buttonHandler)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refresh()
    }
    
    
    // MARK: - Typealiases
    
    public typealias SelectAction = (ActionSheet, ActionSheetItem) -> ()
    
    
    // MARK: - Init properties
    
    public var presenter: ActionSheetPresenter
    public var selectAction: SelectAction
    
    
    // MARK: - Appearance
    
    public var minimumContentInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    public var preferredPopoverWidth: CGFloat = 300
    public var sectionMargins: CGFloat = 15
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var backgroundView: ActionSheetBackgroundView?
    @IBOutlet weak var stackView: UIStackView?
    @IBOutlet weak var headerViewContainer: ActionSheetHeaderView?
    @IBOutlet weak var headerViewContainerHeight: NSLayoutConstraint?
    @IBOutlet weak var itemsTableView: ActionSheetItemTableView?
    @IBOutlet weak var itemsTableViewHeight: NSLayoutConstraint?
    @IBOutlet weak var buttonsTableView: ActionSheetButtonTableView?
    @IBOutlet weak var buttonsTableViewHeight: NSLayoutConstraint?
    
    @IBOutlet weak var topMargin: NSLayoutConstraint?
    @IBOutlet weak var leftMargin: NSLayoutConstraint?
    @IBOutlet weak var rightMargin: NSLayoutConstraint?
    @IBOutlet weak var bottomMargin: NSLayoutConstraint?
    
    
    // MARK: - Header Properties
    
    open var headerView: UIView?
    
    
    // MARK: - Item Properties
    
    public internal(set) var items = [ActionSheetItem]()
    
    public var itemsHeight: CGFloat { return totalHeight(for: items) }
    
    public lazy var itemHandler = ActionSheetItemHandler(actionSheet: self, itemType: .items)
    
    
    // MARK: - Button Properties
    
    public internal(set) var buttons = [ActionSheetButton]()
    
    public var buttonsHeight: CGFloat { return totalHeight(for: buttons) }
    
    public lazy var buttonHandler = ActionSheetItemHandler(actionSheet: self, itemType: .buttons)
    
    
    // MARK: - Presentation Functions
    
    open func dismiss(completion: @escaping () -> () = {}) {
        presenter.dismiss { completion() }
    }

    open func present(in vc: UIViewController, from view: UIView?, completion: @escaping () -> () = {}) {
        refresh()
        presenter.present(sheet: self, in: vc.rootViewController, from: view, completion: completion)
    }

    open func present(in vc: UIViewController, from item: UIBarButtonItem, completion: @escaping () -> () = {}) {
        refresh()
        presenter.present(sheet: self, in: vc.rootViewController, from: item, completion: completion)
    }

    
    // MARK: - Refresh Functions
    
    open func refresh() {
        applyLegacyAppearance()
        refreshHeader()
        refreshItems()
        refreshButtons()
        stackView?.spacing = sectionMargins
        presenter.refreshActionSheet()
    }
    
    open func refreshHeader() {
        let height = headerView?.frame.height ?? 0
        headerViewContainerHeight?.constant = height
        headerViewContainer?.isHidden = headerView == nil
        guard let view = headerView else { return }
        headerViewContainer?.addSubviewToFill(view)
    }
    
    open func refreshItems() {
        items.forEach { $0.applyAppearance(appearance) }
        itemsTableViewHeight?.constant = itemsHeight
    }
    
    open func refreshButtons() {
        buttonsTableView?.isHidden = buttons.count == 0
        buttons.forEach { $0.applyAppearance(appearance) }
        buttonsTableViewHeight?.constant = buttonsHeight
    }
    
    
    // MARK: - Protected Functions
    
    open func handleTap(on item: ActionSheetItem) {
        reloadData()
        if item.tapBehavior != .dismiss { return selectAction(self, item) }
        self.dismiss { self.selectAction(self, item) }
    }
    
    open func margin(at margin: ActionSheetMargin) -> CGFloat {
        let superview = view.superview
        switch margin {
        case .top: return margin.value(in: superview, minimum: minimumContentInsets.top)
        case .left: return margin.value(in: superview, minimum: minimumContentInsets.left)
        case .right: return margin.value(in: superview, minimum: minimumContentInsets.right)
        case .bottom: return margin.value(in: superview, minimum: minimumContentInsets.bottom)
        }
    }

    open func reloadData() {
        itemsTableView?.reloadData()
        buttonsTableView?.reloadData()
    }
}


// MARK: - Private Functions

private extension ActionSheet {
    
    func setup(_ tableView: UITableView?, with handler: ActionSheetItemHandler) {
        tableView?.delegate = handler
        tableView?.dataSource = handler
        tableView?.alwaysBounceVertical = false
        tableView?.estimatedRowHeight = 44
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.cellLayoutMarginsFollowReadableWidth = false
    }
    
    func totalHeight(for items: [ActionSheetItem]) -> CGFloat {
        return items.reduce(0) { $0 + $1.appearance.height }
    }
}
