import Foundation

@objcMembers
public class PianoIDUserInfo: NSObject {
    
    public let email: String
    public let uid: String
    public let firstName: String
    public let lastName: String
    public let aid: String
    public let updated: Date
    public let linkedSocialAccounts: PianoIDUserInfoSocialAccounts?
    public let customFields: [PianoIDUserInfoCustomField]
    public let allCustomFieldValuesFilled: Bool
    public let needResendConfirmationEmail: Bool
    public let changedEmail: Bool
    public let passwordless: Bool
    
    internal init(
        email: String,
        uid: String,
        firstName: String,
        lastName: String,
        aid: String,
        updated: Date,
        linkedSocialAccounts: PianoIDUserInfoSocialAccounts?,
        customFields: [PianoIDUserInfoCustomField],
        allCustomFieldValuesFilled: Bool,
        needResendConfirmationEmail: Bool,
        changedEmail: Bool,
        passwordless: Bool
    ) {
        self.email = email
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.aid = aid
        self.updated = updated
        self.linkedSocialAccounts = linkedSocialAccounts
        self.customFields = customFields
        self.allCustomFieldValuesFilled = allCustomFieldValuesFilled
        self.needResendConfirmationEmail = needResendConfirmationEmail
        self.changedEmail = changedEmail
        self.passwordless = passwordless
    }
}

@objcMembers
public class PianoIDUserInfoSocialAccounts: NSObject {
    
    let facebookLinked: Bool
    let googleLinked: Bool
    let twitterLinked: Bool
    let linkedInLinked: Bool
    let appleLinked: Bool
    let passwordAvailable: Bool
    
    internal init(
        facebookLinked: Bool,
        googleLinked: Bool,
        twitterLinked: Bool,
        linkedInLinked: Bool,
        appleLinked: Bool,
        passwordAvailable: Bool
    ) {
        self.facebookLinked = facebookLinked
        self.googleLinked = googleLinked
        self.twitterLinked = twitterLinked
        self.linkedInLinked = linkedInLinked
        self.appleLinked = appleLinked
        self.passwordAvailable = passwordAvailable
    }
}

@objcMembers
public class PianoIDUserInfoCustomField: NSObject {
    
    let fieldName: String
    let value: String
    let created: Date
    let emailCreator: String?
    let sortOrder: Int64
    
    internal init(
        fieldName: String,
        value: String,
        created: Date,
        emailCreator: String?,
        sortOrder: Int64
    ) {
        self.fieldName = fieldName
        self.value = value
        self.created = created
        self.emailCreator = emailCreator
        self.sortOrder = sortOrder
    }
}
