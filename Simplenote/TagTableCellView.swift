import Foundation
import AppKit


// MARK: - TagTableCellView
//
@objcMembers
class TagTableCellView: NSTableCellView {

    /// Workaround: In AppKit, TableView Cell Selection works at the Row level
    ///
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            refreshSelectedState()
        }
    }

    /// Indicates if the mouse was last seen inside the receiver's bounds
    ///
    private(set) var mouseInside = false {
        didSet {
            guard oldValue != mouseInside else {
                return
            }

            refreshStyle()
        }
    }

    /// Indicates if the receiver's associated NSTableRowView is *selected*
    ///
    private var selected = false {
        didSet {
            guard oldValue != selected else {
                return
            }

            refreshStyle()
        }
    }

    /// Tracking Areas
    ///
    private lazy var trackingArea: NSTrackingArea = {
        NSTrackingArea(rect: .zero, options: [.inVisibleRect, .activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
    }()


    // MARK: - Overridden Methods

    override func prepareForReuse() {
        super.prepareForReuse()
        mouseInside = false
        selected = false
        imageView?.isHidden = false
        textField?.isEditable = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        refreshStyle()
    }

    func refreshStyle() {
        let theme = VSThemeManager.shared().theme()
        let alphaValue = !selected && mouseInside ? AppKitConstants.alpha0_6 : AppKitConstants.alpha1_0;

        imageView?.wantsLayer = true
        imageView?.alphaValue = alphaValue

        textField?.wantsLayer = true
        textField?.alphaValue = alphaValue
        textField?.textColor = selected ? theme.color(forKey: "tintColor") : theme.color(forKey: "textColor")
    }
}


// MARK: - Tracking Areas
//
extension TagTableCellView {

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        guard trackingAreas.contains(trackingArea) == false else {
            return
        }
        addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        mouseInside = true
        NSCursor.pointingHand.set()
    }

    override func mouseExited(with event: NSEvent) {
        mouseInside = false
        NSCursor.arrow.set()
    }
}


// MARK: - Selection Workaround
//
extension TagTableCellView {

    func refreshSelectedState() {
        guard let row = superview as? NSTableRowView else {
            return
        }

        selected = row.isSelected
    }
}
