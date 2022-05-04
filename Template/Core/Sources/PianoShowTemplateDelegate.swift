import Foundation
import UIKit

@objc public protocol PianoShowTemplateDelegate: PianoTemplateInlineDelegate {
    
    @objc optional func onCustomEvent(eventData: Any)
    
    @objc optional func onClose(eventData: Any)
    
    @objc optional func onCloseAndRefresh(eventData: Any)

    @objc optional func onRegister(eventData: Any)
    
    @objc optional func onLogin(eventData: Any)
    
    @objc optional func onLogout(eventData: Any)
    
}
