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

import UIKit

// MARK: Struct

public struct DataOfferRequiredDataDefinitionBundleFiltersV2: Codable {
    
    // MARK: - Variables
    
    /// the field to filter
    public var field: String = ""
    /// The transformation to be done on the field
    public var transformation: Dictionary<String, String>?
    /// The operator of the filter
    public var `operator`: Dictionary<String, String>? {
        
        return (NSKeyedUnarchiver().decodeDecodable(Dictionary<String, String>?.self, forKey: "operator"))!
    }
}
