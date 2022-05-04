import Foundation

import PianoComposer
import PianoOAuth
import PianoTemplate

public class PianoIDShowFormTask: NSObject {
    
    private let params: ShowFormEventParams
    private let accessToken: String?
    
    public let controller: PianoShowFormController
    
    public var signIn: ((_: @escaping (_:String) -> Void) -> Void)
    public var hideIfCompleted: (() -> Void)? = nil
    public var error: ((Error) -> Void)? = nil
    
    public init(params: ShowFormEventParams, accessToken: String?, signIn: @escaping ((_: @escaping (_:String) -> Void) -> Void)) {
        self.params = params
        self.accessToken = accessToken
        self.signIn = signIn
        
        self.controller = PianoShowFormController(params: params, signIn: self.signIn)
    }
    
    public func show() {
        if let t = accessToken {
            checkFields(accessToken: t)
            return
        }
        
        signIn { token in
            self.checkFields(accessToken: token)
        }
    }
    
    private func checkFields(accessToken: String) {
        if params.hideCompletedFields, let f = hideIfCompleted {
            PianoID.shared.formInfo(aid: PianoID.shared.aid, accessToken: accessToken, formName: params.formName) { info, error in                
                if let i = info, i.hasAllCustomFieldValuesFilled {
                    f()
                    return
                }
                
                self.showForm(accessToken: accessToken)
            }
            return
        }
        
        showForm(accessToken: accessToken)
    }
    
    private func showForm(accessToken: String) {
        controller.accessToken = accessToken
        controller.show()
    }
}
