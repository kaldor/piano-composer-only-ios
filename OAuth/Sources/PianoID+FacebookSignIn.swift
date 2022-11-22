import FBSDKCoreKit
import FBSDKLoginKit

extension PianoID {
    
    @available(tvOS, unavailable)
    internal func facebookSignIn() {
        DispatchQueue.main.async {
            FBSDKLoginKit.LoginManager().logIn(
                permissions: ["public_profile", "email"],
                from: self.authViewController
            ) { result, error in
                if let e = error {
                    self.handleFacebookError(e)
                    return
                }
                
                if let r = result {
                    if r.isCancelled {
                        self.signInCancel()
                        return
                    }
                    
                    if let t = r.token?.tokenString {
                        self.handleFacebook(token: t)
                        return
                    }
                }
                
                self.signInFail(.facebookSignInFailed)
            }
        }
    }
    
    private func handleFacebook(token: String) {
        authViewController?.socialSignInCallback(aid: getAID(), oauthProvider: "facebook", socialToken: token)
    }
    
    private func handleFacebookError(_ error: Error) {
        logError("Facebook sign in failed with error \(error)")
        signInFail(.facebookSignInFailed)
    }

}

extension PianoIDApplicationDelegate {
    
    internal func facebookApplication(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) {
        FBSDKLoginKit.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }        

    internal func facebookApplication(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKLoginKit.ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    internal func facebookApplication(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKLoginKit.ApplicationDelegate.shared.application(application, open: url, options: options)
    }
}
