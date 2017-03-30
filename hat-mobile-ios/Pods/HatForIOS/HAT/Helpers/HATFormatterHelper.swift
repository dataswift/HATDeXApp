/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import Foundation

// MARK: Class

/// A struct for everything that formats something
public class HATFormatterHelper: NSObject {
    
    // MARK: - String to Date formaters
    
    /**
     Formats a date to ISO 8601 format
     
     - parameter date: The date to format
     - returns: String
     */
    public class func formatDateToISO(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return dateFormatter.string(from: date as Date)
    }
    
    /**
     Formats a string into a Date
     
     - parameter string: The string to format to a Date
     - returns: Date
     */
    public class func formatStringToDate(string: String) -> Date? {
        
        // check if the string to format is empty
        if string == "" {
            
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var date = dateFormatter.date(from: string)
        
        // if date is nil try a different format and reformat
        if date == nil {
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = dateFormatter.date(from: string)
        }
        
        // if date is nil try a different format, for twitter format and reformat
        if date == nil {
            
            dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
            date = dateFormatter.date(from: string)
        }
        
        return date
    }
    
    // MARK: - Convert from base64URL to base64
    
    /**
     String extension to convert from base64Url to base64
     
     parameter s: The string to be converted
     
     returns: A Base64 String
     */
    public class func fromBase64URLToBase64(s: String) -> String {
        
        var s = s;
        if (s.characters.count % 4 == 2 ) {
            
            s = s + "=="
        } else if (s.characters.count % 4 == 3 ) {
            
            s = s + "="
        }
        
        s = s.replacingOccurrences(of: "-", with: "+")
        s = s.replacingOccurrences(of: "_", with: "/")
        
        return s
    }
    
}