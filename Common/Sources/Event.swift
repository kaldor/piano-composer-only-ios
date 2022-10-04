import Foundation

public protocol PianoEvent {}

public protocol PianoEventDelegate : AnyObject {
    func onEvent(event: PianoEvent?)
}
