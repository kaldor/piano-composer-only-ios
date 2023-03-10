import Foundation

import PianoCommon
import PianoComposer
import PianoTemplate

import CxenseSDK

/// Piano C1X intergration
@objc public class PianoC1X: NSObject, PianoComposerInterceptor {
    
    private static var configuration: PianoC1XConfiguration? = nil
    
    /// Enable C1X intergration
    ///
    /// - Parameters:
    ///   - configuration: C1X integration configuration
    @objc public static func enable(configuration: PianoC1XConfiguration) {
        PianoC1X.configuration = configuration
        
        Cxense.addEventProcessor(DelayEventProcessor(PianoC1XConfiguration.pageViewEventDelay, PageViewEvent.self))
        PianoComposer.enable(interceptorType: PianoC1X.self)
    }
    
    private var eventLock: Lockable
    
    /// Create instance of PianoC1X
    ///
    /// - Parameters:
    ///   - composer: PianoComposer instance
    public required init(composer: PianoComposer) throws {
        guard let location = PianoC1X.getLocation(composer: composer) else {
            throw PianoError("URL or Content Id is empty")
        }
        
        _ = composer.browserId(Cxense.getPersistentCookie())
        
        let eventQuery = PageViewEvent.Query(
            siteId: PianoC1X.configuration?.siteId ?? "",
            location: location,
            referrer: composer.referrer
        )
        
        eventLock = Cxense.lockEvent(query: eventQuery, duration: PianoC1XConfiguration.eventLockDuration)
        
        Cxense.removeEvent(query: eventQuery)
    }
    
    deinit {
        eventLock.unlock()
    }
    
    /// PianoComposer post-processing
    ///
    /// - Parameters:
    ///   - composer: PianoComposer instance
    public func executed(composer: PianoComposer, params: [String:Any]?) {
        eventLock.unlock()
        
        if let p = params,
           let models = p["models"] as? [String:Any],
           let cxenseCustomerPrefix = models["cxenseCustomerPrefix"] as? String {
            
            let eventBuilder = PageViewEventBuilder
                .makeBuilder(withName: composer.pageViewId, siteId: PianoC1X.configuration?.siteId ?? "")
            
            if !composer.contentId.isEmpty {
                _ = eventBuilder.setContentId(cid: composer.contentId)
            } else if !composer.url.isEmpty {
                _ = eventBuilder.setLocation(loc: composer.url)
            }
            
            if !composer.referrer.isEmpty {
                _ = eventBuilder.setReferrer(ref: composer.referrer)
            }
            
            _ = eventBuilder.setRnd(composer.pageViewId)
            
            var userState = "anon"
            if let uid = models["uid"] as? String, !uid.isEmpty && uid != "anon" {
                _ = eventBuilder.addExternalUserId(uid, withType: cxenseCustomerPrefix)
                
                if let result = models["result"] as? [String:Any],
                   let events = result["events"] as? [Any],
                   let event = events.first(where: { (($0 as? [String:Any])?["eventType"] as? String) == "experienceExecute" }) as? [String:Any],
                   let eventExecutionContext = event["eventExecutionContext"] as? [String:Any],
                   let accessList = eventExecutionContext["accessList"] as? [Any],
                   accessList.count > 0 {
                    userState = "hasActiveAccess"
                } else {
                    userState = "registered"
                }
            }
            
            _ = eventBuilder.addCustomParameter(forKey: "userState", withValue: userState)
            
            guard let event = try? eventBuilder.build() else {
                return
            }
            
            Cxense.reportEvent(event)
        }
    }
    
    public static func recommendations(params: ShowRecommendationsEventParams, renderTemplateUrl: String = "auto") -> PianoShowRecommendationsController {
        return PianoShowRecommendationsController(
            params: params,
            renderTemplateUrl: renderTemplateUrl,
            userId: Cxense.getPersistentCookie()
        )
    }
    
    private class func getLocation(composer: PianoComposer) -> String? {
        if !composer.url.isEmpty {
            return composer.url
        }
        if !composer.contentId.isEmpty {
            return composer.contentId
        }
        return nil
    }
}
