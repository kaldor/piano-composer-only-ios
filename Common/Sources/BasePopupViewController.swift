import Foundation

#if os(iOS)

import UIKit

@objcMembers
open class BasePopupViewController: UIViewController {
    
    private static let bundle = Bundle.load("PianoSDK_PianoCommon", for: BasePopupViewController.self)
    
    fileprivate let closeButtonSize: CGFloat = 44
    
    fileprivate let closeButtonName = "piano_modal_close"
    
    fileprivate(set) public var closeButton: UIButton!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let closeImage = UIImage(named: closeButtonName, in: BasePopupViewController.bundle, compatibleWith: nil)
        closeButton = UIButton(type: .system)        
        closeButton.contentMode = UIView.ContentMode.scaleAspectFit
        closeButton.setImage(closeImage, for: UIControl.State.normal)
        closeButton.autoresizingMask = [.flexibleLeftMargin]
        closeButton.addTarget(self, action: #selector(closeButtonTouchUpInside), for: .touchUpInside)
        view.addSubview(closeButton)
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
    }
    
    open func show() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController {
                var topController = rootViewController
                while (topController.presentedViewController != nil) {
                    topController = topController.presentedViewController!
                }
                
                self.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                self.modalPresentationStyle = UIDevice.current.userInterfaceIdiom == .phone
                ? UIModalPresentationStyle.fullScreen : UIModalPresentationStyle.fullScreen
                topController.present(self, animated: true, completion: nil)
            }
        }
    }
    
    open func close() {
        if let vc = presentingViewController {
            vc.dismiss(animated: true, completion: nil)
        } else {
            if let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController {
                rootViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        closeButton.frame = CGRect(x: view.frame.width - closeButtonSize,
                                   y: getTopMargin(),
                                   width: closeButtonSize,
                                   height: closeButtonSize)
        view.bringSubviewToFront(closeButton)
    }
    
    public func getTopMargin() -> CGFloat {
        let modalTopMargin = view.superview?.frame.minX ?? 0
        return modalTopMargin >= UIApplication.shared.statusBarFrame.height || UIApplication.shared.isStatusBarHidden
            ? 0
            : UIApplication.shared.statusBarFrame.height
    }
    
    @objc fileprivate func closeButtonTouchUpInside(_ sender: UIButton) {
        close()
    }
}

#endif
