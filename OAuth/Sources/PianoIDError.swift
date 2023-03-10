import Foundation

@objc
public enum PianoIDError: Int, Error, CustomStringConvertible {
    
    case invalidAuthorizationUrl = -1
    case cannotGetDeploymentHost = -2
    case signInFailed = -3
    case refreshFailed = -4
    case signOutFailed = -5
    case googleSignInFailed = -6
    case facebookSignInFailed = -7
    case formInfoFailed = -8
    case userInfoFailed = -9
    case userInfoValidationFailed = -10
    
    public var description: String {
        switch self {
            case .invalidAuthorizationUrl:
                return "Invalid authorization URL"
            case .cannotGetDeploymentHost:
                return "Cannot get deployment host for application"
            case .signInFailed:
                return "Sign in failed"
            case .refreshFailed:
                return "Refresh failed"
            case .signOutFailed:
                return "Sign out failed"
            case .googleSignInFailed:
                return "Google sign in failed"
            case .facebookSignInFailed:
                return "Facebook sign in failed"
            case .formInfoFailed:
                return "Form information failed"
            case .userInfoFailed:
                return "User information failed"
            case .userInfoValidationFailed:
                return "User information validation failed"
        }
    }
}
