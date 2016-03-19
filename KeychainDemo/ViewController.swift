//
//  ViewController.swift
//  KeychainDemo
//
//  Created by jiangzhenjie on 16/3/19.
//  Copyright © 2016年 jiangzhenjie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var keychain: Keychain!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.keychain = Keychain(service: "Baidu")
    }
    
    @IBAction func addItem(sender: AnyObject) {
//        addPassword()
        
        // 这个addItem是如果Item存在则更新Item，如果Item不存在，则添加Item
        if self.keychain.addItem(value: "test_password".dataUsingEncoding(NSUTF8StringEncoding)!, account: "Jboy92") {
            print("Succeed")
        } else {
            print(self.keychain.error)
        }
    }

    @IBAction func deleteItem(sender: AnyObject) {
//        deletePassword()
        
        if self.keychain.deleteItem("Jboy92") {
            print("Succeed")
        } else {
            print(self.keychain.error)
        }
    }
    
    @IBAction func updateItem(sender: AnyObject) {
//        updatePassword()
        
        if self.keychain.updateItem(value: "update_password".dataUsingEncoding(NSUTF8StringEncoding)!, account: "Jboy92") {
            print("Succeed")
        } else {
            print(self.keychain.error)
        }
    }
    
    @IBAction func queryItem(sender: AnyObject) {
//        queryPassword()
        
        if let data = self.keychain.queryItem("Jboy92") {
            print(String(data: data, encoding: NSUTF8StringEncoding))
        } else {
            print("No password")
            print(self.keychain.error)
        }
        
    }
    
    func addPassword() {
        
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = "Baidu"
        query[kSecAttrAccount as String] = "Jboy92"
        query[kSecValueData as String] = "test_password".dataUsingEncoding(NSUTF8StringEncoding)

        let status = SecItemAdd(query, nil)
        
        if status == errSecSuccess {
            print("Add password succeed")
        } else {
            print("Add password failed")
        }
    }
    
    func deletePassword() {
        
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = "Baidu"
        query[kSecAttrAccount as String] = "Jboy92"
        
        let status = SecItemDelete(query)
        
        if status == errSecSuccess {
            print("Delete password succeed")
        } else {
            print("Delete password failed");
        }
        
    }
    
    func updatePassword() {
        
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = "Baidu"
        query[kSecAttrAccount as String] = "Jboy92"
        
        var updateAttrs = [String: AnyObject]()
        updateAttrs[kSecValueData as String] = "update_password".dataUsingEncoding(NSUTF8StringEncoding)
        
        let status = SecItemUpdate(query, updateAttrs)
        
        if status == errSecSuccess {
            print("Add password succeed")
        } else {
            print("Add password failed")
        }
        
    }
    
    func queryPassword() {
        
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = "Baidu"
        query[kSecAttrAccount as String] = "Jboy92"
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }
        
        if status == errSecSuccess {
            if let result = result as? NSData {
                print(String(data: result, encoding: NSUTF8StringEncoding))
            }
        } else {
            print("No password");
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

