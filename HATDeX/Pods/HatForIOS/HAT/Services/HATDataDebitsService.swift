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
import SwiftyJSON

// MARK: Struct

public struct HATDataDebitsService {
    
    // MARK: Get Data Debits
    
    /**
     Gets the available data debits for the user
     
     - parameter userToken: A String representing the user's token
     - parameter userDomain: A String representing the user's domain
     - parameter succesfulCallBack: A function of type ([DataDebitObject]) -> Void, executed on a successful result
     - parameter failCallBack: A function of type (DataPlugError) -> Void, executed on an unsuccessful result
     */
    public static func getAvailableDataDebits(userToken: String, userDomain: String, succesfulCallBack: @escaping ([DataDebitObject], String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        let url: String = "https://\(userDomain)/api/v2.6/data-debit"
        
        let headers: Dictionary<String, String> = ["X-Auth-Token": userToken]
        
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .get,
            encoding: Alamofire.URLEncoding.default,
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
                        
                        let message = NSLocalizedString("Server responded with error", comment: "")
                        failCallBack(.generalError(message, statusCode, error))
                    }
                // in case of success call the succesfulCallBack
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if isSuccess {
                        
                        if statusCode == 200 {
                            
                            var arrayToReturn: [DataDebitObject] = []
                            for item in result.arrayValue {
                                
                                guard let dataDebit: DataDebitObject = DataDebitObject.decode(from: item.dictionaryValue) else {
                                    
                                    continue
                                }
                                
                                arrayToReturn.append(dataDebit)
                            }
                            
                            succesfulCallBack(arrayToReturn, token)
                        } else {
                            
                            let message: String = NSLocalizedString("Server response was unexpected", comment: "")
                            failCallBack(.generalError(message, statusCode, nil))
                        }
                        
                    } else {
                        
                        let message: String = NSLocalizedString("Server response was unexpected", comment: "")
                        failCallBack(.generalError(message, statusCode, nil))
                    }
                }
            }
        )
    }
    
    // MARK: - Disable data debit
    
    /**
     Disables the specified data debit
     
     - parameter dataDebitID: A String representing the data debit id to disable
     - parameter userToken: A String representing the user's token
     - parameter userDomain: A String representing the user's domain
     - parameter succesfulCallBack: A function of type ([DataDebitObject]) -> Void, executed on a successful result
     - parameter failCallBack: A function of type (DataPlugError) -> Void, executed on an unsuccessful result
     */
    public static func disableDataDebit(dataDebitID: String, userToken: String, userDomain: String, succesfulCallBack: @escaping (DataDebitObject, String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        let url: String = "https://\(userDomain)/api/v2.6/data-debit/\(dataDebitID)/disable?atPeriodEnd=true"
        
        let headers: Dictionary<String, String> = ["X-Auth-Token": userToken]
        
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .get,
            encoding: Alamofire.URLEncoding.default,
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
                        
                        let message = NSLocalizedString("Server responded with error", comment: "")
                        failCallBack(.generalError(message, statusCode, error))
                    }
                // in case of success call the succesfulCallBack
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if isSuccess {
                        
                        if statusCode == 200 {
                            
                            let dictionary = result.dictionaryValue
                            if let dataDebit: DataDebitObject = DataDebitObject.decode(from: dictionary) {
                                
                                succesfulCallBack(dataDebit, token)
                            } else {
                                
                                let message: String = NSLocalizedString("Could not decode response", comment: "")
                                failCallBack(.generalError(message, statusCode, nil))
                            }
                            
                        } else {
                            
                            let message: String = NSLocalizedString("Server response was unexpected", comment: "")
                            failCallBack(.generalError(message, statusCode, nil))
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
