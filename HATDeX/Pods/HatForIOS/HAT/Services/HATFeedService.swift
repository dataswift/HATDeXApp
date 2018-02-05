/**
 * Copyright (C) 2018 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import SwiftyJSON

// MARK: Struct

public struct HATFeedService {
    
    // MARK: - Get feed
    
    /**
     Gets the she feed from HAT
     
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     - parameter parameters: The parameters to pass in the request, default is empty
     - parameter successCallback: A function of type ([HATFeedObject], String?) that executes on success
     - parameter failed: A function of type (HATTableError) that executes on failure
     */
    static public func getFeed(userDomain: String, userToken: String, parameters: Dictionary<String, Any> = [:], successCallback: @escaping ([HATFeedObject], String?) -> Void, failed: @escaping (HATTableError) -> Void) {
        
        func success(values: [JSON], newToken: String?) {
            
            var arrayToReturn: [HATFeedObject] = []
            for value: JSON in values {
                
                let dict: [String: JSON] = value["data"].dictionaryValue
                if let object: HATFeedObject = HATFeedObject.decode(from: dict) {
                    
                    arrayToReturn.append(object)
                }
            }
            
            successCallback(arrayToReturn, newToken)
        }
        
        HATAccountService.getHatTableValues(
            token: userToken,
            userDomain: userDomain,
            namespace: "she",
            scope: "feed",
            parameters: parameters,
            successCallback: success,
            errorCallback: failed)
    }
}
