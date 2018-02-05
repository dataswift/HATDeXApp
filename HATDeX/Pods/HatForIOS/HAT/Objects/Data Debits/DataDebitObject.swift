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

public struct DataDebitObject: HATObject {
    
    // MARK: - Variables
    
    /// The data debit key
    public var dataDebitKey: String = ""
    /// The date created of the data debit
    public var dateCreated: String = ""
    /// The client object of the data debit
    public var client: DataDebitClientObject
    /// The bundles included in Data Debit
    public var bundles: [DataDebitBundleObject] = []
}
