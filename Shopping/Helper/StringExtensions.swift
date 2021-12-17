//
//  StringExtensions.swift
//  SwiftTest
//
//  Created by Saktheeswaran on 16/09/16.
//  Copyright © 2016 NanoNino. All rights reserved.
//
import UIKit
import Foundation
import CommonCrypto
import MobileCoreServices


enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func toCCEnum() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}


extension NSAttributedString {
    func heightOfAttrbuitedText(_ attrStr: NSAttributedString, width: CGFloat) -> Float {
        let rect: CGRect = attrStr.boundingRect(with: CGSize(width: width, height: CGFloat(10000)), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return Float(rect.size.height)
    }
}
extension String {

        /// Handles 10 or 11 digit phone numbers
        ///
        /// - Returns: formatted phone number or original value
    public func toPhoneNumber(str :String) -> String {
        let digits = self.digits
        if str == "+91" {
            return digits.replacingOccurrences(of: "(\\d{5})(\\d{5})", with: "$1-$2", options: .regularExpression, range: nil)
        }
        else if str == "+34" {
            return digits.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: nil)
        }
        else {
            return self
        }
    }

    
    func toBase64()->String{
        
        let data = self.data(using: String.Encoding.utf8)
        return (data?.base64EncodedString())!
        //return data!.base64EncodedStringWithOptions(NSData.Base64EncodingOptions(rawValue: 0))
        
    }
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return String(data: data, encoding: .utf8)
        }
        return ""
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined(separator: "")
    }
    
    func htmlAttributedString(attributes: [String : Any]? = .none) -> NSAttributedString? {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return .none }
        guard let html = try? NSMutableAttributedString(
            data: data,
            options: convertToNSAttributedStringDocumentReadingOptionKeyDictionary([convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.documentType): convertFromNSAttributedStringDocumentType(NSAttributedString.DocumentType.html)]),
            documentAttributes: .none) else { return .none }
        
        
        html.setAttributes(convertToOptionalNSAttributedStringKeyDictionary(attributes), range: NSRange(0..<html.length))
        
        return html
    }
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    func sha1() -> String
    {
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes
            {
                _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map
        {
            String(format: "%02hhx", $0)
        }
        return hexBytes.joined()
    }
    
    func hmac(algorithm: HMACAlgorithm, key: String) -> String
    {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength()))
        let length : Int = Int(strlen(cKey!))
        let data : Int = Int(strlen(cData!))
        CCHmac(algorithm.toCCEnum(), cKey!,length , cData!, data, &result)
        
        let hmacData:NSData = NSData(bytes: result, length: (Int(algorithm.digestLength())))
        
        var bytes = [UInt8](repeating: 0, count: hmacData.length)
        hmacData.getBytes(&bytes, length: hmacData.length)
        
        var hexString = ""
        for byte in bytes
        {
            hexString += String(format:"%02hhx", UInt8(byte))
        }
        return hexString
    }
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height:height )
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
}

extension UIFont {
    
    
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringDocumentReadingOptionKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.DocumentReadingOptionKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.DocumentReadingOptionKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentAttributeKey(_ input: NSAttributedString.DocumentAttributeKey) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentType(_ input: NSAttributedString.DocumentType) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    var containsImage: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }
    var containsAudio: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }
    var containsVideo: Bool {
        let mimeType = self.mimeType()
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeMovie)
    }

}

