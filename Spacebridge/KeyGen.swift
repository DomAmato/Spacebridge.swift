//
//  KeyGen.swift
//  Spacebridge
//
//  Created by Dominic Amato on 11/5/19.
//  Copyright © 2019 Hologram. All rights reserved.
//

import Foundation

func createRSAKey() -> SecKey? {
    let tag = "io.hologram.keys.spacebridge".data(using: .utf8)!
    // By assigning a value of true to the private key’s kSecAttrIsPermanent attribute, you store it in the default keychain while creating it.
    let attributes: [String: Any] =
        [kSecAttrKeyType as String:            kSecAttrKeyTypeRSA,
         kSecAttrKeySizeInBits as String:      2048,
         kSecPrivateKeyAttrs as String:
            [kSecAttrIsPermanent as String:    true,
             kSecAttrApplicationTag as String: tag]
    ]
    
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
        print(error!)
        return nil
    }
    
    // Get the public key
    //    let publicKey = SecKeyCopyPublicKey(privateKey)
    return privateKey
}

func createDSAKey() -> SecKey? {
    let tag = "io.hologram.keys.spacebridge".data(using: .utf8)!
    // By assigning a value of true to the private key’s kSecAttrIsPermanent attribute, you store it in the default keychain while creating it.
    let attributes: [String: Any] =
        [kSecAttrKeyType as String:            kSecAttrKeyTypeDSA,
         kSecAttrKeySizeInBits as String:      2048,
         kSecPrivateKeyAttrs as String:
            [kSecAttrIsPermanent as String:    true,
             kSecAttrApplicationTag as String: tag]
    ]
    
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
        print(error!)
        return nil
    }
    
    // Get the public key
    //    let publicKey = SecKeyCopyPublicKey(privateKey)
    return privateKey
}

func GetSpacebridgeKey() -> SecKey? {
    let tag = "io.hologram.keys.spacebridge".data(using: .utf8)!

    let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                   kSecAttrApplicationTag as String: tag,
                                   kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                   kSecReturnRef as String: true]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(getquery as CFDictionary, &item)
    if status != errSecSuccess {
        // Key probably doesnt exist
        return createRSAKey()
    }
    return item as! SecKey
    
}
