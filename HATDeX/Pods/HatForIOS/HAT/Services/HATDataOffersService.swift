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

public struct HATDataOffersService {
    
    // MARK: - Get available data offers
    
    /**
     Gets the available data offers based on the merchants requested
     
     - parameter userDomain: The user's domain
     - parameter applicationToken: The application token
     - parameter merchants: The merchants to get the offers from
     - parameter succesfulCallBack: A function of type ([DataOfferObject], String?) -> Void, executed on a successful result
     - parameter failCallBack: A function of type (DataPlugError) -> Void, executed on an unsuccessful result
     */
    public static func getAvailableDataOffers(isBeta: Bool = false, userDomain: String, applicationToken: String, merchants: [String]?, succesfulCallBack: @escaping ([DataOfferObject], String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        let mutableURL: NSMutableString
        
        if userDomain.contains("hubofallthings") {
            
            mutableURL = "https://databuyer.hubofallthings.com/api/v2/offersWithClaims"
        } else {
            
            mutableURL = "https://databuyer.hubat.net/api/v2/offersWithClaims"
        }
        
        if merchants != nil {
            
            for (index, merchant) in (merchants?.enumerated())! {
                
                if index == 0 {
                    
                    mutableURL.append("?")
                } else {
                    
                    mutableURL.append("&")
                }
                
                mutableURL.append("merchant=\(merchant)")
            }
        }
        
        let url: String = mutableURL as String
        let headers: Dictionary<String, String> = ["X-Auth-Token": applicationToken]
        
        HATNetworkHelper.asynchronousRequest(url, method: .get, encoding: Alamofire.JSONEncoding.default, contentType: ContentType.json, parameters: [:], headers: headers, completion: { (response: HATNetworkHelper.ResultType) -> Void in
            
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
                    
                    var returnValue: [DataOfferObject] = []
                    
                    for item in result.arrayValue {
                        
                        returnValue.append(DataOfferObject(dictionary: item.dictionaryValue))
                    }
                    
                    succesfulCallBack(returnValue, token)
                } else {
                    
                    let message: String = NSLocalizedString("Server response was unexpected", comment: "")
                    failCallBack(.generalError(message, statusCode, nil))
                }
            }
        })
    }
    
    // MARK: - Claim offer
    
    /**
     Gets the available data plugs for the user to enable
     
     - parameter userDomain: The user's domain
     - parameter applicationToken: The application token
     - parameter offerID: The offer id to claim
     - parameter succesfulCallBack: A function of type ([HATDataPlugObject]) -> Void, executed on a successful result
     - parameter failCallBack: A function of type (Void) -> Void, executed on an unsuccessful result
     */
    public static func claimOffer(userDomain: String, applicationToken: String, offerID: String, succesfulCallBack: @escaping (String, String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        let url: String
        
        if userDomain.contains("hubofallthings") {
            
            url = "https://databuyer.hubofallthings.com/api/v2/offer/\(offerID)/claim"
        } else {
            
            url = "https://databuyer.hubat.net/api/v2/offer/\(offerID)/claim"
        }
        
        let headers: Dictionary<String, String> = ["X-Auth-Token": applicationToken]
        
        HATNetworkHelper.asynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.json, parameters: [:], headers: headers, completion: { (response: HATNetworkHelper.ResultType) -> Void in
            
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
                    
                    let dictionaryResponse = result.dictionaryValue
                    
                    if let claimed = dictionaryResponse["dataDebitId"]?.stringValue {
                        
                        succesfulCallBack(claimed, token)
                    } else {
                        
                        let message: String = NSLocalizedString("Server response was unexpected", comment: "")
                        failCallBack(.generalError(message, statusCode, nil))
                    }
                } else {
                    
                    let message: String = NSLocalizedString("Server response was unexpected", comment: "")
                    failCallBack(.generalError(message, statusCode, nil))
                }
            }
        })
    }
    
    // MARK: - Redeem offer
    
    /**
     Redeems cash offer
     
     - parameter userDomain: The user's domain
     - parameter appToken: The databuyer app token
     - parameter succesfulCallBack: A function to execute on successful response returning the server message and the renewed user's token
     - parameter failCallBack: A function to execute on failed response returning the error
     */
    public static func redeemOffer(userDomain: String, appToken: String, succesfulCallBack: @escaping (String, String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        let url: String
        
        if userDomain.contains("hubofallthings") {
            
            url = "https://databuyer.hubofallthings.com/api/v2/user/redeem/cash"
        } else {
            
            url = "https://databuyer.hubat.net/api/v2/user/redeem/cash"
        }
        
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .get,
            encoding: Alamofire.URLEncoding.default,
            contentType: ContentType.json,
            parameters: [:],
            headers: ["X-Auth-Token": appToken],
            completion: { (response: HATNetworkHelper.ResultType) -> Void in
                
                switch response {
                    
                case .error(let error, let statusCode):
                    
                    if error.localizedDescription == "The request timed out." || error.localizedDescription == "The Internet connection appears to be offline." {
                        
                        failCallBack(.noInternetConnection)
                    } else {
                        
                        let message: String = NSLocalizedString("Server responded with error", comment: "")
                        failCallBack(.generalError(message, statusCode, error))
                    }
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if statusCode == 200 && isSuccess {
                        
                        let dictionaryResponse = result.dictionaryValue
                        if let message: String = dictionaryResponse["message"]?.stringValue {
                            
                            succesfulCallBack(message, token)
                        }
                    }
                }
        }
        )
    }
    
    // MARK: - Get Merchants
    
    /**
     Gets available merchants from HAT
     
     - parameter userToken: The users token
     - parameter userDomain: The user's domain name
     - parameter succesfulCallBack: A function to execute on successful response returning the merchants array and the renewed user's token
     - parameter failCallBack: A function to execute on failed response returning the error
     */
    public static func getMerchants(userToken: String, userDomain: String, succesfulCallBack: @escaping ([String], String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        let url: String = "https://\(userDomain)/api/v2/data/dex/databuyer"
        
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .get,
            encoding: Alamofire.URLEncoding.default,
            contentType: ContentType.json,
            parameters: ["take": 1, "orderBy": "date", "ordering": "descending"],
            headers: ["X-Auth-Token": userToken],
            completion: { (response: HATNetworkHelper.ResultType) -> Void in
                
                switch response {
                    
                case .error(let error, let statusCode):
                    
                    if error.localizedDescription == "The request timed out." || error.localizedDescription == "The Internet connection appears to be offline." {
                        
                        failCallBack(.noInternetConnection)
                    } else {
                        
                        let message = NSLocalizedString("Server responded with error", comment: "")
                        failCallBack(.generalError(message, statusCode, error))
                    }
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if statusCode == 200 && isSuccess && !result.arrayValue.isEmpty {
                        
                        let dictionaryResponse = result.arrayValue[0].dictionaryValue
                        if let tempDictionary = dictionaryResponse["data"]?.dictionaryValue {
                            
                            if let merchants = tempDictionary["merchants"]?.arrayValue {
                                
                                var arrayToReturn: [String] = []
                                for merchant in merchants {
                                    
                                    if let merchantString = merchant.string {
                                        
                                        arrayToReturn.append(merchantString)
                                    }
                                }
                                succesfulCallBack(arrayToReturn, token)
                            }
                        }
                    } else if statusCode == 200 && isSuccess && result.arrayValue.isEmpty {
                        
                        succesfulCallBack([], token)
                    } else if statusCode == 401 {
                        
                        let message: String = NSLocalizedString("Server responded with error", comment: "")
                        failCallBack(.generalError(message, statusCode, nil))
                    }
                }
        }
        )
    }
    
    // MARK: - Claim offer wrapper
    
    /**
     Claims and enables the offer
     
     - parameter offer: The offer to claim and enable
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     - parameter merchants: The merchants used to get the offer, defaults to an empty array
     - parameter succesfulCallBack: A function returning the new offer object and the the user's token
     - parameter failCallBack: A function executing of failure
     */
    public static func claimOfferWrapper(offer: DataOfferObject, userDomain: String, userToken: String, merchants: [String]? = [], succesfulCallBack: @escaping (DataOfferObject, String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        func gotDatabuyerToken(appToken: String, newUserToken: String?) {
            
            func offerAccepted(status: String) {
                
                func filterOffers(offers: [DataOfferObject], newUserToken: String?) {
                    
                    let filteredOffer = offers.filter {
                        
                        if $0.dataOfferID == offer.dataOfferID {
                            
                            return true
                        }
                        
                        return false
                    }
                    
                    guard !filteredOffer.isEmpty else {
                        
                        failCallBack(.noValueFound)
                        return
                    }
                    
                    let offer = filteredOffer[0]
                    succesfulCallBack(offer, newUserToken)
                }
                
                HATDataOffersService.getAvailableDataOffers(
                    userDomain: userDomain,
                    applicationToken: appToken,
                    merchants: merchants,
                    succesfulCallBack: filterOffers,
                    failCallBack: failCallBack)
            }
            
            func success(dataDebitID: String, renewedUserToken: String?) {
                
                func dataDebitStatus(isEnabled: Bool) {
                    
                    if !isEnabled {
                        
                        HATDataPlugsService.approveDataDebit(
                            dataDebitID,
                            userToken: userToken,
                            userDomain: userDomain,
                            succesfulCallBack: offerAccepted,
                            failCallBack: failCallBack)
                    } else {
                        
                        offerAccepted(status: "enabled")
                    }
                }
                
                HATDataPlugsService.checkDataDebit(
                    dataDebitID,
                    userToken: userToken,
                    userDomain: userDomain,
                    succesfulCallBack: dataDebitStatus,
                    failCallBack: failCallBack)
            }
            
            HATDataOffersService.claimOffer(
                userDomain: userDomain,
                applicationToken: appToken,
                offerID: offer.dataOfferID,
                succesfulCallBack: success,
                failCallBack: failCallBack)
        }
        
        func failedGettingToken(error: JSONParsingError) {
            
            failCallBack(.generalError("Failed to get the token", 401, nil))
        }
        
        HATService.getApplicationTokenFor(
            serviceName: DataBuyer.name,
            userDomain: userDomain,
            userToken: userToken,
            resource: DataBuyer.source,
            succesfulCallBack: gotDatabuyerToken,
            failCallBack: failedGettingToken)
    }
}
