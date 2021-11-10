import Foundation

import PianoCommon

fileprivate enum EventType: Int {
    case showLogin
    case showTemplate
    case setResponseVariable
    case nonSite
    case userSegmentTrue
    case userSegmentFalse
    case meterActive
    case meterExpired
    case experienceExecute
    case experienceExecutionFailed
}

@objcMembers
public class PianoEndpoint: NSObject {

    public static var production: PianoEndpoint {
        PianoEndpoint(api: "https://buy.piano.io", composer: "https://c2.piano.io")
    }
    
    public static var productionEurope: PianoEndpoint {
        PianoEndpoint(api: "https://buy-eu.piano.io", composer: "https://c2-eu.piano.io")
    }

    public static var productionAustralia: PianoEndpoint {
        PianoEndpoint(api: "https://buy-au.piano.io", composer: "https://c2-au.piano.io")
    }

    public static var productionAsiaPacific: PianoEndpoint {
        PianoEndpoint(api: "https://buy-ap.piano.io", composer: "https://c2-ap.piano.io")
    }

    public static var sandbox: PianoEndpoint {
        PianoEndpoint(api: "https://sandbox.piano.io", composer: "https://c2.sandbox.piano.io")
    }

    public let api: String
    public let composer: String

    public init(api: String, composer: String) {
        self.api = api
        self.composer = composer
    }

    public convenience init(url: String) {
        self.init(api: url, composer: url)
    }
}

@objc
public protocol PianoComposerInterceptor {
    
    @objc init(composer: PianoComposer) throws
    @objc optional func executed(composer: PianoComposer, params: [String:Any]?)
}

@objcMembers
public class PianoComposer: NSObject {
    
    private static var interceptorTypes: [PianoComposerInterceptor.Type] = []
    
    public static func enable<T: PianoComposerInterceptor>(interceptorType: T.Type) {
        interceptorTypes.append(interceptorType)
    }

    public static let pianoIdUserProviderName = "piano_id"

    public weak var delegate: PianoComposerDelegate?

    fileprivate let eventTypeMap = ["showLogin": EventType.showLogin,
                                    "showTemplate": EventType.showTemplate,
                                    "setResponseVariable": EventType.setResponseVariable,
                                    "nonSite": EventType.nonSite,
                                    "userSegmentTrue": EventType.userSegmentTrue,
                                    "userSegmentFalse": EventType.userSegmentFalse,
                                    "meterActive": EventType.meterActive,
                                    "meterExpired": EventType.meterExpired,
                                    "experienceExecutionFailed": EventType.experienceExecutionFailed,
                                    "experienceExecute": EventType.experienceExecute]

    fileprivate let userAgent = ComposerHelper.generateUserAgent()
    fileprivate let executeAction = "/xbuilder/experience/executeMobile"
    fileprivate let showTemplateAction = "/checkout/template/show"

    fileprivate var interceptors: [PianoComposerInterceptor] = []
    fileprivate var session: URLSession
    fileprivate var dataTask: URLSessionDataTask?

    public let aid: String
    public let protocolVersion: Int = 1
    public let submitType: String = "manual"
    public let pageViewId = ComposerHelper.generatePageViewId()
    public var endpoint: PianoEndpoint
    public var tags: Set<String> = Set<String>()
    public var customVariables: Dictionary<String, String> = Dictionary<String, String>()
    public var customParams: CustomParams?
    public var url: String = "/"
    public var referrer: String = ""
    public var zoneId: String = ""
    public var debug: Bool = false
    public var userToken: String = ""
    public var contentCreated: String = ""
    public var contentAuthor: String = ""
    public var contentSection: String = ""
    public var contentIsNative: Bool? = nil
    public var gaClientId: String = ""
    public var browserId: String = ""

    @available(*, deprecated, message: "Use endpoint property")
    public var endpointUrl: String {
        endpoint.api
    }

    fileprivate override init() {
        aid = ""
        fatalError("init() has not been implemented")
    }

    public init(aid: String, endpoint: PianoEndpoint) {
        self.aid = aid
        self.endpoint = endpoint

        session = PianoComposer.createSession()

        super.init()
    }

    public convenience init(aid: String) {
        self.init(aid: aid, endpoint: PianoEndpoint.production)
    }

    @available(*, deprecated, message: "Use PianoComposer(aid: \"...\", endpoint: PianoEndpoint(...))")
    public convenience init(aid: String, endpointUrl: String) {
        self.init(aid: aid, endpoint: PianoEndpoint(api: endpointUrl, composer: endpointUrl))
    }

    @available(*, deprecated, message: "Use PianoComposer(aid: \"...\", endpoint: PianoEndpoint.sandbox)")
    public convenience init(aid: String, sandbox: Bool) {
        self.init(aid: aid, endpoint: sandbox ? PianoEndpoint.sandbox : PianoEndpoint.production)
    }

    fileprivate static func createSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = nil
        config.httpCookieAcceptPolicy = .never
        return URLSession(configuration: config)
    }

    public func endpointUrl(_ endpointUrl: String) -> PianoComposer {
        endpoint = PianoEndpoint(url: endpointUrl)
        return self
    }

    public func tag(_ tag: String) -> PianoComposer {
        tags.insert(tag)
        return self
    }

    public func tags(_ tagCollection: Array<String>) -> PianoComposer {
        for tag in tagCollection {
            tags.insert(tag)
        }

        return self
    }

    public func customVariable(name: String, value: String) -> PianoComposer {
        customVariables[name] = value
        return self
    }

    public func clearCustomVariables() -> PianoComposer {
        customVariables.removeAll()
        return self
    }

    public func customParams(_ customParams: CustomParams) -> PianoComposer {
        self.customParams = customParams
        return self
    }

    public func url(_ url: String) -> PianoComposer {
        self.url = url
        return self
    }

    public func userToken(_ userToken: String) -> PianoComposer {
        self.userToken = userToken
        return self
    }

    public func referrer(_ referrer: String) -> PianoComposer {
        self.referrer = referrer
        return self
    }

    public func zoneId(_ zoneId: String) -> PianoComposer {
        self.zoneId = zoneId
        return self
    }

    public func debug(_ debug: Bool) -> PianoComposer {
        self.debug = debug
        return self
    }

    public func contentCreated(_ contentCreated: String) -> PianoComposer {
        self.contentCreated = contentCreated
        return self
    }

    public func contentAuthor(_ contentAuthor: String) -> PianoComposer {
        self.contentAuthor = contentAuthor
        return self
    }

    public func contentSection(_ contentSection: String) -> PianoComposer {
        self.contentSection = contentSection
        return self
    }

    public func contentIsNative(_ contentIsNative: Bool?) -> PianoComposer {
        self.contentIsNative = contentIsNative
        return self
    }

    public func delegate(_ delegate: PianoComposerDelegate?) -> PianoComposer {
        self.delegate = delegate
        return self
    }

    public func gaClientId(_ gaClientId: String) -> PianoComposer {
        self.gaClientId = gaClientId
        return self
    }
    
    public func browserId(_ browserId: String) -> PianoComposer {
        self.browserId = browserId
        return self
    }

    /**
        Start experiences executing
    */
    @discardableResult public func execute() -> PianoComposer {
        PianoLogger.getLogger().logLevel = debug ? .all : .off

        if dataTask != nil {
            dataTask?.cancel()
        }

        if let requestUrl = URL(string: "\(getBaseUrl(isExecute: true))\(executeAction)") {
            PianoComposer.interceptorTypes.forEach { type in
                do {
                    interceptors.append(try type.init(composer: self))
                } catch {
                    PianoLogger.error(message: error.localizedDescription)
                    return
                }
            }
            
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"
            request.httpBody = createRequestBody()
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

            PianoLogger.debug(message: "Composer request = \(requestUrl.absoluteURL)")
            dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
                DispatchQueue.main.async {
                    //UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }

                let result = self.taskCompleted(data: data, response: response, error: error)
                DispatchQueue.main.async {
                    self.delegate?.composerExecutionCompleted?(composer: self)
                }
                
                self.interceptors.forEach { interceptor in
                    interceptor.executed?(composer: self, params: result)
                }
            })

            if dataTask != nil {
                DispatchQueue.main.async {
                    //UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
                dataTask?.resume()
            }
        }

        return self
    }

    fileprivate func taskCompleted(data: Data?, response: URLResponse?, error: Error?) -> [String:Any]? {
        if let error = error {
            PianoLogger.debug(message: error.localizedDescription)
            return nil
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 && data != nil else {
            PianoLogger.debug(message: "Incorrect response: httpStatus=\((response as? HTTPURLResponse)?.statusCode ?? 0), data size=\(data?.count ?? 0)")

            if let responseData = data, responseData.count > 0 {
                PianoLogger.debug(message: "Response data:\n\(String(data: responseData, encoding: .utf8) ?? "")")
            }
            return nil
        }

        PianoLogger.debug(message: "Response data:\n\(String(data: data!, encoding: .utf8) ?? "")")
        guard let responseObject = JSONSerializationUtil.deserializeResponse(response: response!, responseData: data!) else {
            PianoLogger.debug(message: "Cannot deserialize response")
            return nil
        }

        if let errors = (responseObject["errors"] as? [Any]){
            processErrorResult(errorResult: ErrorResult(array: errors))
        }

        if let models = (responseObject["models"] as? [String: Any]) {
            saveCookie(dict: models)
            if let result = models["result"] as? [String: Any] {
                processExperienceResult(result: ExperienceResult(dict: result))
            }
        }
        
        return responseObject
    }

    fileprivate func getBaseUrl(isExecute: Bool) -> String {
        isExecute ? endpoint.composer : endpoint.api
    }

    fileprivate func clearCookie() {
        Preferences.saveCookies(data: Preferences.CookieData(xbc: "", tbc: "", tac: ""))
    }

    fileprivate func saveCookie(dict: [String: Any]) {
        var xbc = ""
        if let xbcDict = dict["xbc"] as? [String: Any] {
            xbc = xbcDict["cookie_value"] as? String ?? ""
        }

        var tbc = ""
        if let tbcDict = dict["tbc"] as? [String: Any] {
            tbc = tbcDict["cookie_value"] as? String ?? ""
        }

        var tac = ""
        if let tacDict = dict["tac"] as? [String: Any] {
            tac = tacDict["cookie_value"] as? String ?? ""
        }

        let appTimezoneOffset = dict["timezone_offset"] as? Int ?? 0
        let visitTimeout = dict["visit_timeout"] as? Int ?? 30 // 30 minutes

        PianoLogger.debug(message: "Save cookies and preferences")
        Preferences.saveCookies(data: Preferences.CookieData(xbc: xbc, tbc: tbc, tac: tac))
        Preferences.saveVisitPreferences(visitPreferences: Preferences.VisitPreferences(appTimezoneOffset: appTimezoneOffset, visitTimeout: visitTimeout * 60000))
    }

    fileprivate func createRequestBody() -> Data? {
        let storedCookies = Preferences.loadCookies()
        let visitTuple = getOrCreateVisitId()

        let requestParamBuilder = RequestParamBuilder()
                .add(name: "protocol_version", value: "\(protocolVersion)")
                .add(name: "timezone_offset", value: "\(ComposerHelper.getTimeZoneOffset())")
                .add(name: "debug", value: "\(debug)")
                .add(name: "aid", value: aid)
                .add(name: "xbc", value: storedCookies.xbc)
                .add(name: "tbc", value: storedCookies.tbc)
                .add(name: "tac", value: storedCookies.tac)
                .add(name: "user_agent", value: userAgent)
                .add(name: "custom_variables", value: JSONSerializationUtil.serializeObjectToJSONString(object: customVariables))
                .add(name: "user_token", value: userToken)
                .add(name: "url", value: url)
                .add(name: "referer", value: referrer)
                .add(name: "tags", value: tags.joined(separator: ","))
                .add(name: "pageview_id", value: pageViewId)
                .add(name: "visit_id", value: visitTuple.visitId)
                .add(name: "new_visit", value: "\(visitTuple.isNew)")
                .add(name: "zone", value: zoneId)
                .add(name: "submit_type", value: submitType)
                .add(name: "content_created", value: contentCreated)
                .add(name: "content_author", value: contentAuthor)
                .add(name: "content_section", value: contentSection)
                .add(name: "sdk_version", value: ComposerHelper.getSdkVersion())

        if contentIsNative != nil {
            requestParamBuilder.add(name: "content_is_native", value: "\(contentIsNative!)")
        }

        if customParams != nil {
            requestParamBuilder.add(name: "custom_params", value: JSONSerializationUtil.serializeObjectToJSONString(object: customParams!.toDictionary()))
        }
        
        if !browserId.isEmpty {
            requestParamBuilder.add(name: "new_bid", value: browserId)
        }

        return requestParamBuilder.build().data(using: String.Encoding.utf8)
    }

    fileprivate func getOrCreateVisitId() -> (visitId: String, isNew: Bool) {
        var isNew: Bool = false
        let visit = Preferences.loadVisit()
        let visitPreferences = Preferences.loadVisitPreferences()

        if visit.isEmpty() || visit.isExpired(visitPreferences: visitPreferences) {
            visit.id = ComposerHelper.generateVisitId()
            isNew = true
        }

        visit.time = Date().timeIntervalSince1970
        Preferences.saveVisit(visit: visit)
        return (visitId: visit.id, isNew: isNew)
    }

    fileprivate func processExperienceResult(result: ExperienceResult) {
        guard !result.events.isEmpty else {
            return
        }

        PianoLogger.debug(message: "Experience result processing:")
        DispatchQueue.main.async {
            self.fireEvents(events: result.events)
        }
    }

    fileprivate func processErrorResult(errorResult: ErrorResult) {
        guard !errorResult.errors.isEmpty else {
            return
        }

        PianoLogger.debug(message: "Experience error result processing: ")
        for e in errorResult.errors {
            PianoLogger.debug(message: "Error field=\(e.field) key=\(e.key) msg=\(e.message)")
        }
    }

    fileprivate func fireEvents(events: Array<XpEvent>) {
        for event in events {
            if let eventType = eventTypeMap[event.eventType] {
                switch eventType {
                case .showLogin:
                    delegate?.showLogin?(composer: self, event: event, params: ShowLoginEventParams(dict: event.eventParams))
                case .showTemplate:
                    let showTemplateEventParams = ShowTemplateEventParams(dict: event.eventParams)
                    if showTemplateEventParams != nil {
                        showTemplateEventParams!.endpointUrl = getBaseUrl(isExecute: false)
                        showTemplateEventParams!.templateUrl = buildTemplateUrl(event: event, params: showTemplateEventParams!)
                        showTemplateEventParams!.trackingId = event.eventExecutionContext?.trackingId ?? ""
                    }
                    delegate?.showTemplate?(composer: self, event: event, params: showTemplateEventParams)
                case .setResponseVariable:
                    delegate?.setResponseVariable?(composer: self, event: event, params: SetResponseVariableParams(dict: event.eventParams))
                case .nonSite:
                    delegate?.nonSite?(composer: self, event: event)
                case .userSegmentTrue:
                    delegate?.userSegmentTrue?(composer: self, event: event)
                case .userSegmentFalse:
                    delegate?.userSegmentFalse?(composer: self, event: event)
                case .meterActive:
                    delegate?.meterActive?(composer: self, event: event, params: PageViewMeterEventParams(dict: event.eventParams))
                case .meterExpired:
                    delegate?.meterExpired?(composer: self, event: event, params: PageViewMeterEventParams(dict: event.eventParams))
                case .experienceExecutionFailed:
                    delegate?.experienceExecutionFailed?(composer: self, event: event, params: FailureEventParams(dict: event.eventParams))
                case .experienceExecute:
                    delegate?.experienceExecute?(composer: self, event: event, params: ExperienceExecuteEventParams(dict: event.eventParams))
                }

                PianoLogger.debug(message: "Fire event \(event.eventType)(id = \(event.eventModuleParams?.moduleId ?? ""), name = \(event.eventModuleParams?.moduleName ?? ""))")
            }  else {
                PianoLogger.debug(message: "EventType \"\(event.eventType)\" has not item in eventTypeMap")
            }
        }
        delegate = nil
    }

    fileprivate func buildTemplateUrl(event: XpEvent, params: ShowTemplateEventParams) -> String {
        let requestParamBuilder = RequestParamBuilder()
                .add(name: "aid", value: aid)
                .add(name: "url", value: url)
                .add(name: "templateId", value: params.templateId)
                .add(name: "templateVariantId", value: params.templateVariantId)
                .add(name: "userToken", value: userToken)
                .add(name: "customVariables", value: JSONSerializationUtil.serializeObjectToJSONString(object: customVariables))
                .add(name: "debug", value: "\(debug)")
                .add(name: "displayMode", value: "\(DisplayMode.inline)")
                .add(name: "tags", value: tags.joined(separator: ","))
                .add(name: "trackingId", value: event.eventExecutionContext?.trackingId ?? "")
                .add(name: "zone", value: zoneId)
                .add(name: "contentAuthor", value: contentAuthor)
                .add(name: "contentSection", value: contentSection)
                .add(name: "gaClientId", value: gaClientId)
                .add(name: "os", value: "ios")

        if let activeMeters = event.eventExecutionContext?.activeMeters {
            let jsonCompatibleArray = activeMeters.map({ meter in meter.toDictionary() })
            requestParamBuilder.add(name: "activeMeters", value:JSONSerializationUtil.serializeObjectToJSONString(object: jsonCompatibleArray))
        }

        let templateUrl: String = "\(getBaseUrl(isExecute: false))\(showTemplateAction)?\(requestParamBuilder.build())"
        return templateUrl
    }

    public static func clearStoredData() {
        Preferences.clearPreferences()
    }
}
