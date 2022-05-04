import Foundation

@objc public protocol PianoComposerDelegate: AnyObject {
    /**
     Show login event
     */
    @objc optional func showLogin(composer: PianoComposer, event: XpEvent, params: ShowLoginEventParams?)
    
    /**
     Show template event
     */
    @objc optional func showTemplate(composer: PianoComposer, event: XpEvent, params: ShowTemplateEventParams?)
    
    /**
     Show form event
     */
    @objc optional func showForm(composer: PianoComposer, event: XpEvent, params: ShowFormEventParams?)
    
    /**
     Show recommendations event
     */
    @objc optional func showRecommendations(composer: PianoComposer, event: XpEvent, params: ShowRecommendationsEventParams?)
    
    /**
     Set response variable event
     */
    @objc optional func setResponseVariable(composer: PianoComposer, event: XpEvent, params: SetResponseVariableParams?)
    
    /**
     Non site action event
     */
    @objc optional func nonSite(composer: PianoComposer, event: XpEvent)
    
    /**
     User segment true event
     */
    @objc optional func userSegmentTrue(composer: PianoComposer, event: XpEvent)
    
    /**
     User segment false event
     */
    @objc optional func userSegmentFalse(composer: PianoComposer, event: XpEvent)
    
    /**
     Meter active event
     */
    @objc optional func meterActive(composer: PianoComposer, event: XpEvent, params: PageViewMeterEventParams?)
    
    /**
     Meter expired event
     */
    @objc optional func meterExpired(composer: PianoComposer, event: XpEvent, params: PageViewMeterEventParams?)
    
    /**
     Exeperience execution failed
     */
    @objc optional func experienceExecutionFailed(composer: PianoComposer, event: XpEvent, params: FailureEventParams?)
    
    /**
     Exeperience execute event
     */
    @objc optional func experienceExecute(composer: PianoComposer, event: XpEvent, params: ExperienceExecuteEventParams?)    
    
    /**
     Event fired by composer when async task was completed and all experience event fired
     */
    @objc optional func composerExecutionCompleted(composer: PianoComposer)
}
