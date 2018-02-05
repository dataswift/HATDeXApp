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

import SwiftyJSON

// MARK: Struct

public struct HATGoogleCalendarService {
    
    // MARK: - Get application token for twitter
    
    /**
     Gets application token for twitter
     
     - parameter plug: The plug object to extract the info we need to get the AppToken
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     - parameter successful: An @escaping (String, String?) -> Void method executed on a successful response
     - parameter failed: An @escaping (JSONParsingError) -> Void) method executed on a failed response
     */
    public static func getAppTokenForGoogleCalendar(plug: HATDataPlugObject, userDomain: String, userToken: String, successful: @escaping (String, String?) -> Void, failed: @escaping (JSONParsingError) -> Void) {
        
        HATService.getApplicationTokenFor(
            serviceName: plug.plug.name,
            userDomain: userDomain,
            userToken: userToken,
            resource: plug.plug.url,
            succesfulCallBack: successful,
            failCallBack: failed)
    }
    
    // MARK: - Get calendar data
    
    /**
     Fetched the user's posts from facebook with v2 API's
     
     - parameter userToken: The authorisation token to authenticate with the hat
     - parameter userDomain: The user's domain
     - parameter parameters: The parameters to use in the request
     - parameter successCallback: An @escaping ([HATGoogleCalendarObject], String?) -> Void) method executed on a successful response
     - parameter errorCallback: An @escaping (HATTableError) -> Void) method executed on a failed response
     */
    public static func getCalendarEvents(userToken: String, userDomain: String, parameters: Dictionary<String, String>, successCallback: @escaping (_ array: [HATGoogleCalendarObject], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        func sendObjectBack(jsonArray: [JSON], token: String?) {
            
            var array: [HATGoogleCalendarObject] = []
            
            for object: JSON in jsonArray {
                
                if let objectToAdd: HATGoogleCalendarObject = HATGoogleCalendarObject.decode(from: object.dictionaryValue) {
                    
                    array.append(objectToAdd)
                }
            }
            
            successCallback(array, token)
        }
        
        HATAccountService.getHatTableValues(
            token: userToken,
            userDomain: userDomain,
            namespace: GoogleCalendar.sourceName,
            scope: GoogleCalendar.tableName,
            parameters: parameters,
            successCallback: sendObjectBack,
            errorCallback: errorCallback)
    }

}
