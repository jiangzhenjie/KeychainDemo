//
//  Keychain.swift
//  KeychainDemo
//
//  Created by jiangzhenjie on 16/3/19.
//  Copyright © 2016年 jiangzhenjie. All rights reserved.
//

import Foundation
import Security

class Keychain {
    
    let service: String
    let accessGroup: String?
    var error: NSError?
    
    init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
    
}

extension Keychain {
    
    /**
     创建一个GenericPassword查询
     
     - parameter account: account
     
     - returns: query
     */
    private func query(account: String?) -> [String: AnyObject] {
        
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service
        query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        
        if let account = account {
            query[kSecAttrAccount as String] = account
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        return query
    }
    
    /**
     如果Item存在则更新Item，如果Item不存在，则添加Item
     
     - parameter value:   item value
     - parameter account: account
     
     - returns: 添加成功返回true，其他情况返回false
     */
    func addItem(value value: NSData, account: String) -> Bool {
        
        var query = self.query(account)
        
        if let _ = queryItem(account) {
            return updateItem(value: value, account: account)
        }
        
        query[kSecValueData as String] = value
        
        let status = SecItemAdd(query, nil)
        error = self.dynamicType.error(status)
        
        if status == errSecSuccess {
            return true
        }
        
        return false
    }
    
    /**
     更新Item
     
     - parameter value:   value data
     - parameter account: account
     
     - returns: 更新成功返回true，其他情况返回false
     */
    func updateItem(value value: NSData, account: String) -> Bool {
        
        let query = self.query(account)
        
        var updateQuery = [String: AnyObject]()
        updateQuery[kSecValueData as String] = value
        
        let status = SecItemUpdate(query, updateQuery)
        error = self.dynamicType.error(status)
        
        if status == errSecSuccess {
            return true
        }
        
        return false
    }
    
    /**
     删除Item
     
     - parameter account: account
     
     - returns: 成功返回true，其他情况返回false
     */
    func deleteItem(account: String) -> Bool {
        
        let query = self.query(account)
        
        let status = SecItemDelete(query)
        error = self.dynamicType.error(status)
        
        if status == errSecSuccess {
            return true
        }
        
        return false
    }
    
    /**
     查询Item
     
     - parameter account: account
     
     - returns: (status, data)
     */
    func queryItem(account: String) -> NSData? {
        
        var query = self.query(nil)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }
        
        error = self.dynamicType.error(status)
        
        if status == errSecSuccess {
            return result as? NSData
        }
        
        return nil
    }
    
    
    /**
     查询accessGroup和service下的所有Item
     
     - returns: all items
     */
    func allItems() -> [[String: AnyObject]]? {
        
        var allItems: [[String: AnyObject]]?
        
        var query = self.query(nil)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }
        
        error = self.dynamicType.error(status)
        
        if status == errSecSuccess {
            if let items = result as? [[String: AnyObject]] {
                allItems = items
            } else {
                print(result)
            }
        }
        
        return allItems
    }
}

extension Keychain {
    
    /**
     查询keychain下所有的GenericPassword Item
     包含所有accessGroup, service, account
     
     - returns: all items
     */
    class func allItems() -> [[String: AnyObject]]? {
        
        var allItems: [[String: AnyObject]]?
        
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }
        
        if status == errSecSuccess {
            if let items = result as? [[String: AnyObject]] {
                allItems = prettify(items)
            }
        }
        
        return allItems
    }
    
    private class func prettify(items: [[String: AnyObject]]) -> [[String: AnyObject]] {
        let items = items.map { (attributes) -> [String: AnyObject] in
            
            var item = [String: AnyObject]()
            
            item["class"] = String(kSecClassGenericPassword)
            
            if let service = attributes[kSecAttrService as String] as? String {
                item["service"] = service
            }
            
            if let accessGroup = attributes[kSecAttrAccessGroup as String] as? String {
                item["accessGroup"] = accessGroup
            }
            
            if let account = attributes[kSecAttrAccount as String] as? String {
                item["account"] = account
            }
            
            if let data = attributes[kSecValueData as String] as? NSData {
                if let text = String(data: data, encoding: NSUTF8StringEncoding) {
                    item["value"] = text
                } else {
                    item["value"] = data
                }
            }
            
            if let synchronizable = attributes[kSecAttrSynchronizable as String] as? Bool {
                item["synchronizable"] = synchronizable ? "true" : "false"
            }
            
            return item
        }
        return items
    }
    
    private class func error(status: OSStatus) -> NSError {
        
        var domain = ""
        
        switch status {
        case errSecSuccess:
            domain = "errSecSuccess"
        case errSecUnimplemented:
            domain = "errSecUnimplemented"
        case errSecIO:
            domain = "errSecIO"
        case errSecOpWr:
            domain = "errSecOpWr"
        case errSecParam:
            domain = "errSecParam"
        case errSecAllocate:
            domain = "errSecAllocate"
        case errSecUserCanceled:
            domain = "errSecUserCanceled"
        case errSecBadReq:
            domain = "errSecBadReq"
        case errSecInternalComponent:
            domain = "errSecInternalComponent"
        case errSecNotAvailable:
            domain = "errSecNotAvailable"
        case errSecDuplicateItem:
            domain = "errSecDuplicateItem"
        case errSecItemNotFound:
            domain = "errSecItemNotFound"
        case errSecInteractionNotAllowed:
            domain = "errSecInteractionNotAllowed"
        case errSecDecode:
            domain = "errSecDecode"
        case errSecAuthFailed:
            domain = "errSecAuthFailed"
        default:
            domain = "Unkown Error"
            
        }
        
        return NSError(domain: domain, code: Int(status), userInfo: nil)
    }
    
}
