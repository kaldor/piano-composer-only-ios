import Foundation

import PianoOAuth
import PianoComposer
import PianoTemplate

extension PianoID {
    
    public func form(params: ShowFormEventParams) -> PianoIDShowFormTask {
        PianoIDShowFormTask(params: params, accessToken: PianoID.shared.currentToken?.accessToken) { callback in
            self.signIn { result, error in
                if error != nil {
                    return
                }
                
                guard let r = result else {
                    return
                }
                
                callback(r.token.accessToken)
            }
        }
    }
}
