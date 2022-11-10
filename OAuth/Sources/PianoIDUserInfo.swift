import Foundation

@objcMembers
public class PianoIDUserInfo: NSObject {
    
    public let email: String
    public let uid: String
    public let firstName: String
    public let lastName: String
    public let aid: String
    public let updated: Date
    public let linkedSocialAccounts: [String]
    public let passwordAvailable: Bool
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
        linkedSocialAccounts: [String],
        passwordAvailable: Bool,
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
        self.passwordAvailable = passwordAvailable
        self.customFields = customFields
        self.allCustomFieldValuesFilled = allCustomFieldValuesFilled
        self.needResendConfirmationEmail = needResendConfirmationEmail
        self.changedEmail = changedEmail
        self.passwordless = passwordless
    }
}

@objcMembers
public class PianoIDUserInfoCustomField: NSObject {
    
    let fieldName: String
    let fieldValue: String
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
        self.fieldValue = value
        self.created = created
        self.emailCreator = emailCreator
        self.sortOrder = sortOrder
    }
}
