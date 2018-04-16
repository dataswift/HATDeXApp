//
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

import Alamofire

// MARK: Struct

public struct HATExternalAppsService {
    
    // MARK: - Get external apps
    
    /**
     Gets the apps from HAT
     
     - parameter userToken: The user's token, required to complete this request
     - parameter userDomain: The user's domain, required to complete this request
     - parameter completion: A function to execute on success with the apps and the new token
     - parameter failCallBack: A function to execute on fail that takes the error produced
     */
    public static func getExternalApps(userToken: String, userDomain: String, completion: @escaping (([HATApplicationObject], String?) -> Void), failCallBack: @escaping ((HATTableError) -> Void)) {
        
        let url: String = "https://\(userDomain)/api/v2/applications"
        let headers: [String: String] = ["x-auth-token": userToken]
        
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .get,
            encoding: Alamofire.JSONEncoding.default,
            contentType: ContentType.json,
            parameters: [:],
            headers: headers,
            completion: { (response: HATNetworkHelper.ResultType) -> Void in
                
                switch response {
                    
                // in case of error call the failCallBack
                case .error(let error, let statusCode):
                    
                    if error.localizedDescription == "The request timed out." || error.localizedDescription == "The Internet connection appears to be offline." {
                        
                        failCallBack(.noInternetConnection)
                    } else {
                        
                        let message: String = NSLocalizedString("Server responded with error", comment: "")
                        failCallBack(.generalError(message, statusCode, error))
                    }
                // in case of success call succesfulCallBack
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if isSuccess && statusCode != 401 {
                        
                        if let array = result.array {
                            
                            var arrayToReturn: [HATApplicationObject] = []
                            
                            for item in array {
                                
                                if let object: HATApplicationObject = HATApplicationObject.decode(from: item.dictionaryValue) {
                                    
                                    arrayToReturn.append(object)
                                }
                            }
                            
                            completion(arrayToReturn, token)
                        }
                    } else {
                        
                        let message: String = NSLocalizedString("Server response was unexpected", comment: "")
                        failCallBack(.generalError(message, statusCode, nil))
                    }
                }
            }
        )
    }
    
    // MARK: - Setup external apps
    
    /**
     Sets up the app
     
     - parameter userToken: The user's token, required to complete this request
     - parameter userDomain: The user's domain, required to complete this request
     - parameter applicationID: The application id, required to complete this request
     - parameter completion: A function to execute on success with the apps and the new token
     - parameter failCallBack: A function to execute on fail that takes the error produced
     */
    public static func setUpApp(userToken: String, userDomain: String, applicationID: String, completion: @escaping ((HATApplicationObject, String?) -> Void), failCallBack: @escaping ((HATTableError) -> Void)) {
        
        let url: String = "https://\(userDomain)/api/v2/applications/\(applicationID)/setup"
        let headers: [String: String] = ["x-auth-token": userToken]
        
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .get,
            encoding: Alamofire.JSONEncoding.default,
            contentType: ContentType.json,
            parameters: [:],
            headers: headers,
            completion: { (response: HATNetworkHelper.ResultType) -> Void in
                
                switch response {
                    
                // in case of error call the failCallBack
                case .error(let error, let statusCode):
                    
                    if error.localizedDescription == "The request timed out." || error.localizedDescription == "The Internet connection appears to be offline." {
                        
                        failCallBack(.noInternetConnection)
                    } else {
                        
                        let message: String = NSLocalizedString("Server responded with error", comment: "")
                        failCallBack(.generalError(message, statusCode, error))
                    }
                // in case of success call succesfulCallBack
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if isSuccess && statusCode != 401 {
                        
                        if let dict = result.dictionary {
                            
                            if let object: HATApplicationObject = HATApplicationObject.decode(from: dict) {
                                
                                completion(object, token)
                            } else {
                                
                                let message: String = NSLocalizedString("Server response was unexpected", comment: "")
                                failCallBack(.generalError(message, statusCode, nil))
                            }
                        }
                    } else {
                        
                        let message: String = NSLocalizedString("Server response was unexpected", comment: "")
                        failCallBack(.generalError(message, statusCode, nil))
                    }
                }
            }
        )
    }
}
