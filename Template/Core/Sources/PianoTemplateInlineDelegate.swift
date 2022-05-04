import UIKit

@objc public protocol PianoTemplateInlineDelegate: AnyObject {
    
    @objc func findViewBySelector(selector: String) -> UIView?
}
