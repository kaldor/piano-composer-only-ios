import GoogleSignIn

extension PianoID {
    
    internal func googleSignIn() {
        DispatchQueue.main.async {
            if let viewController = self.authViewController {
                GoogleSignIn.GIDSignIn.sharedInstance.signIn(with: GIDConfiguration(clientID: self.googleClientId), presenting: viewController) { user, error in
                    if let e = error {
                        if let ge = e as? GIDSignInError, ge.code == GIDSignInError.canceled {
                            self.signInCancel()
                            return
                        }
                        
                        self.logError("Google sign in failed with error \(e)")
                        self.signInFail(.googleSignInFailed)
                        return
                    }
                    
                    guard let u = user, let token = u.authentication.idToken else {
                        self.signInFail(.googleSignInFailed)
                        return
                    }
                    
                    self.authViewController?.socialSignInCallback(aid: self.getAID(), oauthProvider: "google", socialToken: token)
                }
            }
        }
    }
}

extension PianoIDApplicationDelegate {
    
    internal func googleApplication(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return GoogleSignIn.GIDSignIn.sharedInstance.handle(url)
    }

    internal func googleApplication(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        return GoogleSignIn.GIDSignIn.sharedInstance.handle(url)
    }

    internal func googleApplication(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GoogleSignIn.GIDSignIn.sharedInstance.handle(url)
    }
}
