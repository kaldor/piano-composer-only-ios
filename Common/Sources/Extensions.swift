import Foundation

extension Bundle {
    
    public static func load(_ bundleName: String, for aClass: AnyClass) -> Bundle? {
        if let p = Bundle.main.path(forResource: bundleName, ofType: "bundle") {
            return Bundle(path: p)
        }
        
        let bundle = Bundle(for: aClass)
        if let p  = bundle.path(forResource: bundleName, ofType: "bundle") {
            return Bundle(path: p)
        }
        return bundle
    }
}
