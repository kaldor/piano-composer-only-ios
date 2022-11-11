import AuthenticationServices
import CommonCrypto
import UIKit
import SafariServices

import PianoCommon

@objcMembers
public class PianoID: NSObject {

    public static let shared: PianoID = PianoID()

    public weak var delegate: PianoIDDelegate?
    internal weak var authViewController: PianoIDOAuthViewController?

    private let sandbox = "https://sandbox.piano.io"
    private let idProd = "https://id.piano.io"
    private let apiProd = "https://buy.piano.io"

    private let deploymentHostPath = "/api/v3/anon/mobile/sdk/id/deployment/host"
    private let authorizationPath = "/id/api/v1/identity/vxauth/authorize"
    private let passwordlessPath = "/id/api/v1/identity/passwordless/authorization/code"
    private let tokenPath = "/id/api/v1/identity/oauth/token"
    private let logoutPath = "/id/api/v1/identity/logout"
    private let formInfoPath = "/id/api/v1/identity/userinfo"

    private var urlSession: URLSession

    public var aid: String = ""
    public var isSandbox = false
    public var endpointUrl: String = ""
    public var deploymentHost: String = ""
    public var signUpEnabled = false
    public var widgetType: WidgetType = .login
    public var stage = ""
    public var presentingViewController: UIViewController?

    public var googleClientId: String = ""
    internal var nativeSignInWithAppleEnabled = false

    private let urlSchemePrefix = "io.piano.id"
    private let urlSchemePath = "success"

    private var redirectScheme: String {
        get {
            "\(urlSchemePrefix).\(aid.lowercased())://"
        }
    }

    private var redirectURI: String {
        get {
            "\(redirectScheme)\(urlSchemePath)"
        }
    }

    private var apiHost: String {
        if endpointUrl.isEmpty {
            return isSandbox ? sandbox : apiProd
        } else {
            return endpointUrl
        }
    }

    fileprivate var _currentToken: PianoIDToken?
    public var currentToken: PianoIDToken? {
        if _currentToken == nil {
            _currentToken = PianoIDTokenStorage.shared.loadToken(aid: getAID())
        }
        return _currentToken
    }

    private override init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = nil
        config.httpCookieAcceptPolicy = .never
        urlSession = URLSession(configuration: config)
        super.init()
    }

    public func getAID() -> String {
        assert(!aid.isEmpty, "PIANO_ID: Piano AID should be specified")
        return aid
    }

    public func signIn(completion: ((PianoIDSignInResult?, Error?) -> Void)? = nil) {
        getDeploymentHost(
            success: { (host) in
                if let url = self.prepareAuthorizationUrl(host: host) {
                    self.startAuthSession(url: url, completion: completion)
                } else {
                    self.signInFail(.invalidAuthorizationUrl, completion: completion)
                }
            },
            fail: {
                self.signInFail(.cannotGetDeploymentHost, completion: completion)
            }
        )
    }

    fileprivate func passwordlessSignIn(code: String) {
        getDeploymentHost(
            success: { (host) in
                if let url = self.preparePasswrodlessUrl(host: host, code: code) {
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    let dataTask = self.urlSession.dataTask(with: request) { (data, response, error) in
                        if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let responseData = data {
                            if let token = self.parseToken(response: response!, responseData: responseData) {
                                self.signInSuccess(token, false)
                                return
                            }
                        }
                    }

                    dataTask.resume()
                }
            },
            fail: {
                self.signInFail(.cannotGetDeploymentHost)
            }
        )
    }

    public func signOut(token: String) {
        _currentToken = nil
        PianoIDTokenStorage.shared.removeToken(aid: getAID())

        getDeploymentHost(
            success: { (host) in
                if let url = self.prepareSignOutUrl(host: host, token: token) {
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"

                    let dataTask = self.urlSession.dataTask(with: request) { (data, response, error) in
                        if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                            self.signOutSuccess()
                        } else {
                            self.signOutFail()
                        }
                    }

                    dataTask.resume()
                }
            },
            fail: {
                self.signOutFail()
            }
        )
    }

    public func refreshToken(_ refreshToken: String, completion: @escaping (PianoIDToken?, PianoIDError?) -> Void) {
        getDeploymentHost(
            success: { (host) in
                if let url = self.prepareRefreshTokenUrl(host: host) {
                    let body: [String: Any] = [
                        "client_id": self.getAID(),
                        "grant_type": "refresh_token",
                        "refresh_token": refreshToken
                    ]

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = JSONSerializationUtil.serializeObjectToJSONData(object: body)
                    let dataTask = self.urlSession.dataTask(with: request) { (data, response, error) in
                        if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let responseData = data {
                            if let token = self.parseToken(response: response!, responseData: responseData) {
                                self._currentToken = token
                                _ = PianoIDTokenStorage.shared.saveToken(token, aid: self.getAID())
                                
                                completion(token, nil)
                                return
                            }
                        }

                        completion(nil, PianoIDError.refreshFailed)
                    }

                    dataTask.resume()
                }
            },
            fail: {
                completion(nil, PianoIDError.cannotGetDeploymentHost)
            }
        )
    }
    
    public func formInfo(aid: String, accessToken: String, formName: String? = nil, completion: @escaping (PianoIDFormInfo?, PianoIDError?) -> Void) {
        getDeploymentHost(
            success: { (host) in
                if let url = self.prepareFormInfoUrl(host: host, aid: aid, formName: formName) {
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue(accessToken, forHTTPHeaderField: "Authorization")
                    let dataTask = self.urlSession.dataTask(with: request) { (data, response, error) in
                        if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let responseData = data {
                            if let formInfo = self.parseFormInfo(response: httpResponse, responseData: responseData) {
                                completion(formInfo, nil)
                                return
                            }
                        }

                        completion(nil, PianoIDError.formInfoFailed)
                    }

                    dataTask.resume()
                }
            },
            fail: {
                completion(nil, PianoIDError.cannotGetDeploymentHost)
            }
        )
    }
    
    public func formInfo(accessToken: String, formName: String? = nil, completion: @escaping (PianoIDFormInfo?, PianoIDError?) -> Void) {
        formInfo(aid: getAID(), accessToken: accessToken, completion: completion)
    }
    
    public func userInfo(aid: String, accessToken: String, formName: String, completion: @escaping (PianoIDUserInfo?, PianoIDError?) -> Void) {
        getDeploymentHost(
            success: { (host) in
                if let url = self.prepareFormInfoUrl(host: host, aid: aid, formName: formName) {
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue(accessToken, forHTTPHeaderField: "Authorization")
                    let dataTask = self.urlSession.dataTask(with: request) { (data, response, error) in
                        if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let responseData = data {
                            if let userInfo = self.parseUserInfo(response: httpResponse, responseData: responseData) {
                                completion(userInfo, nil)
                                return
                            }
                        }

                        completion(nil, PianoIDError.userInfoFailed)
                    }

                    dataTask.resume()
                }
            },
            fail: {
                completion(nil, PianoIDError.cannotGetDeploymentHost)
            }
        )
    }
    
    public func userInfo(accessToken: String, formName: String, completion: @escaping (PianoIDUserInfo?, PianoIDError?) -> Void) {
        userInfo(aid: getAID(), accessToken: accessToken, formName: formName, completion: completion)
    }
    
    public func putUserInfo(
        aid: String,
        accessToken: String,
        formName: String,
        customFields: [String:String],
        completion: @escaping (PianoIDUserInfo?, PianoIDError?) -> Void
    ) {
        getDeploymentHost(
            success: { (host) in
                if let url = self.prepareUpdateUserInfoUrl(host: host, aid: aid) {
                    var request = URLRequest(url: url)
                    request.httpMethod = "PUT"
                    request.setValue(accessToken, forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let fields: [[String:Any]] = customFields.map { k,v in
                        [
                            "field_name": k,
                            "value": v
                        ]
                    }
                    
                    let body : [String:Any] = [
                        "form_name": formName,
                        "custom_field_values": fields
                    ]
                    
                    request.httpBody = JSONSerializationUtil.serializeObjectToJSONData(object: body)
                    
                    let dataTask = self.urlSession.dataTask(with: request) { (data, response, error) in
                        if error == nil, let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode != 200 {
                                completion(nil, httpResponse.statusCode == 400 ? PianoIDError.userInfoValidationFailed : PianoIDError.userInfoFailed)
                                return
                            }
                            
                            if let responseData = data, let userInfo = self.parseUserInfo(response: httpResponse, responseData: responseData) {
                                completion(userInfo, nil)
                                return
                            }
                        }
                        completion(nil, PianoIDError.userInfoFailed)
                    }

                    dataTask.resume()
                }
            },
            fail: {
                completion(nil, PianoIDError.cannotGetDeploymentHost)
            }
        )
    }
    
    public func putUserInfo(
        accessToken: String,
        formName: String,
        customFields: [String:String],
        completion: @escaping (PianoIDUserInfo?, PianoIDError?) -> Void
    ) {
        putUserInfo(aid: getAID(), accessToken: accessToken, formName: formName, customFields: customFields, completion: completion)
    }

    fileprivate func parseToken(response: URLResponse, responseData: Data) -> PianoIDToken? {
        if let responseObject = JSONSerializationUtil.deserializeResponse(response: response, responseData: responseData) {
            if let accessToken = responseObject["access_token"] as? String,
               let refreshToken = responseObject["refresh_token"] as? String {
                return PianoIDToken(accessToken: accessToken, refreshToken: refreshToken)
            }
        }

        return .none
    }
    
    fileprivate func parseFormInfo(response: URLResponse, responseData: Data) -> PianoIDFormInfo? {
        if let responseObject = JSONSerializationUtil.deserializeResponse(response: response, responseData: responseData) {
            let hasAllCustomFieldValuesFilled = responseObject["has_all_custom_field_values_filled"] as? Bool ?? false
            return PianoIDFormInfo(hasAllCustomFieldValuesFilled: hasAllCustomFieldValuesFilled)
        }
        
        return .none
    }
    
    fileprivate func parseUserInfo(response: URLResponse, responseData: Data) -> PianoIDUserInfo? {
        if let responseObject = JSONSerializationUtil.deserializeResponse(response: response, responseData: responseData) {
            var customFields: [PianoIDUserInfoCustomField] = []
            if let cfs = responseObject["custom_field_values"] as? [[String:Any]] {
                cfs.forEach { cf in
                    customFields.append(
                        PianoIDUserInfoCustomField(
                            fieldName: cf["field_name"] as? String ?? "",
                            value: cf["value"] as? String ?? "",
                            created: Date(timeIntervalSince1970: cf["created"] as? Double ?? 0),
                            emailCreator: cf["email_creator"] as? String,
                            sortOrder: cf["sort_order"] as? Int64 ?? 0
                        )
                    )
                }
            }
            
            return PianoIDUserInfo(
                email: responseObject["email"] as? String ?? "",
                uid: responseObject["uid"] as? String ?? "",
                firstName: responseObject["first_name"] as? String ?? "",
                lastName: responseObject["last_name"] as? String ?? "",
                aid: responseObject["aid"] as? String ?? "",
                updated: Date(timeIntervalSince1970: responseObject["updated"] as? Double ?? 0),
                linkedSocialAccounts: responseObject["linked_social_accounts"] as? [String] ?? [],
                passwordAvailable: (responseObject["password_available"] as? Bool) ?? false,
                customFields: customFields,
                allCustomFieldValuesFilled: responseObject["has_all_custom_field_values_filled"] as? Bool ?? false,
                needResendConfirmationEmail: responseObject["need_resend_confirmation_email"] as? Bool ?? false,
                changedEmail: responseObject["changed_email"] as? Bool ?? false,
                passwordless: responseObject["passwordless"] as? Bool ?? false
            )
        }
        
        return .none
    }

    fileprivate func getDeploymentHost(success: @escaping (String) -> Void, fail: @escaping () -> Void) {
        guard deploymentHost.isEmpty else {
            success(deploymentHost)
            return
        }

        if let url = prepareDeploymentHostUrl(host: apiHost) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let responseData = data {
                    if let responseObject = JSONSerializationUtil.deserializeResponse(response: response!, responseData: responseData), let host = responseObject["data"] as? String {
                        success(host.isEmpty ? self.idProd : host)
                        return
                    }
                }

                fail()
            }

            dataTask.resume()
        }
    }

    private func prepareDeploymentHostUrl(host: String) -> URL? {
        var urlComponents = URLComponents(string: host)
        urlComponents?.path = deploymentHostPath
        urlComponents?.queryItems = [
            URLQueryItem(name: "aid", value: getAID()),
        ]

        return urlComponents?.url
    }

    private func prepareAuthorizationUrl(host: String) -> URL? {
        guard var urlComponents = URLComponents(string: host) else {
            return nil
        }

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: getAID()),
            URLQueryItem(name: "screen", value: widgetType.description),
            URLQueryItem(name: "disable_sign_up", value: "\(!signUpEnabled)"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "is_sdk", value: "\(true)"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
        ]
        
        if !stage.isEmpty {
            queryItems.append(URLQueryItem(name: "stage", value: stage))
        }

        var nativeOAuthProviders: [String] = []
        nativeOAuthProviders.append(SocialOAuthProvider.google.description)
        nativeOAuthProviders.append(SocialOAuthProvider.facebook.description)

        if nativeSignInWithAppleEnabled {
            nativeOAuthProviders.append(SocialOAuthProvider.apple.description)
        }

        if !nativeOAuthProviders.isEmpty {
            queryItems.append(URLQueryItem(name: "oauth_providers", value: nativeOAuthProviders.joined(separator: ",")))
        }

        urlComponents.path = authorizationPath
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }

    private func preparePasswrodlessUrl(host: String, code: String) -> URL? {
        guard var urlComponents = URLComponents(string: host) else {
            return nil
        }

        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "aid", value: getAID()),
            URLQueryItem(name: "passwordless_token", value: code)
        ]

        urlComponents.queryItems = queryItems
        urlComponents.path = passwordlessPath
        return urlComponents.url
    }

    private func prepareRefreshTokenUrl(host: String) -> URL? {
        guard var urlComponents = URLComponents(string: host) else {
            return nil
        }

        urlComponents.path = tokenPath
        return urlComponents.url
    }

    private func prepareSignOutUrl(host: String, token: String) -> URL? {
        guard var urlComponents = URLComponents(string: host) else {
            return nil
        }

        urlComponents.path = logoutPath
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: getAID()),
            URLQueryItem(name: "token", value: token),
        ]

        return urlComponents.url
    }
    
    private func prepareFormInfoUrl(host: String, aid: String, formName: String?) -> URL? {
        guard var urlComponents = URLComponents(string: host) else {
            return nil
        }
        
        urlComponents.path = formInfoPath
        
        var queryItems = [
            URLQueryItem(name: "client_id", value: aid)
        ]
        
        if let f = formName {
            queryItems.append(URLQueryItem(name: "form_name", value: f))
        }
        
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
    }
    
    private func prepareUpdateUserInfoUrl(host: String, aid: String) -> URL? {
        guard var urlComponents = URLComponents(string: host) else {
            return nil
        }
        
        urlComponents.path = formInfoPath
        
        urlComponents.queryItems = [
            URLQueryItem(name: "aid", value: aid)
        ]
        
        return urlComponents.url
    }

    private func startAuthSession(url: URL, completion: ((PianoIDSignInResult?, Error?) -> Void)? = nil) {
        if authViewController != nil {
            return
        }

        DispatchQueue.main.async {
            if let presentingViewController = self.getPresentingViewController() {
                let authViewController = PianoIDOAuthViewController(title: "", url: url, completion: completion)
                presentingViewController.present(authViewController, animated: true, completion: nil)
                self.authViewController = authViewController
            }
        }
    }

    internal func getPresentingViewController() -> UIViewController? {
        if let viewController = presentingViewController {
            return viewController
        }

        var topViewController: UIViewController?
        if let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController {
            topViewController = rootViewController
            while (topViewController?.presentedViewController != nil) {
                topViewController = topViewController?.presentedViewController!
            }
        }

        return topViewController
    }

    internal func handleUrl(_ url: URL) -> Bool {
        guard url.absoluteString.lowercased().hasPrefix(urlSchemePrefix) else {
            return false
        }

        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryParams = urlComponents.queryItems {
            if let accessToken = queryParams.first(where: { $0.name == "access_token" })?.value,
               let refreshToken = queryParams.first(where: { $0.name == "refresh_token" })?.value {

                let token = PianoIDToken(accessToken: accessToken, refreshToken: refreshToken)
                signInSuccess(token, false)
                return true
            }

            if let code = queryParams.first(where: { $0.name == "code" })?.value {
                passwordlessSignIn(code: code)
                return true
            }
        }

        return false
    }

    internal func signInSuccess(_ token: PianoIDToken, _ isNewUser: Bool, completion: ((PianoIDSignInResult?, Error?) -> Void)? = nil) {
        _currentToken = token
        _ = PianoIDTokenStorage.shared.saveToken(token, aid: getAID())

        if (delegate?.signIn != nil) {
            let result = PianoIDSignInResult(token, isNewUser)
            signInHandler {
                self.delegate!.signIn!(result: result, withError: nil)
                completion?(result, nil)
            }
        }
    }

    internal func signInFail(_ error: PianoIDError!, completion: ((PianoIDSignInResult?, Error?) -> Void)? = nil) {
        if (delegate?.signIn != nil) {
            signInHandler {
                self.delegate!.signIn!(result: nil, withError: error)
                completion?(nil, error)
            }
        }
    }

    internal func signInCancel() {
        if (delegate?.cancel != nil) {
            signInHandler {
                self.delegate!.cancel!()
            }
        } else if let vc = self.authViewController, let presentingViewController = vc.presentingViewController {
            presentingViewController.dismiss(animated: true)
        }
    }

    internal func signOutSuccess() {
        if (delegate?.signOut != nil) {
            DispatchQueue.main.async {
                self.delegate!.signOut!(withError: nil)
            }
        }
    }

    internal func signOutFail() {
        if (delegate?.signOut != nil) {
            DispatchQueue.main.async {
                self.delegate!.signOut!(withError: PianoIDError.signOutFailed)
            }
        }
    }

    internal func logError(_ message: String) {
        print("PianoID: \(message)")
    }

    private func signInHandler(handler: @escaping () -> Void) {
        DispatchQueue.main.async {
            if let vc = self.authViewController, let presentingViewController = vc.presentingViewController {
                presentingViewController.dismiss(animated: true, completion: {
                    handler()
                })
            } else {
                handler()
            }
        }
    }
}

@available(iOS 9.0, *)
extension PianoID: SFSafariViewControllerDelegate {

    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        signInCancel()
    }
}

@available(iOS 13.0, *)
extension PianoID: ASWebAuthenticationPresentationContextProviding {

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        presentingViewController?.view.window
                ?? (delegate as? UIViewController)?.view.window
                ?? UIApplication.shared.keyWindow
                ?? ASPresentationAnchor()
    }
}

