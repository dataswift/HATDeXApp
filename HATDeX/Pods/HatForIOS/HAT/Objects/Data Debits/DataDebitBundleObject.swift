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

// MARK: Struct

public struct DataDebitBundleObject: HATObject {

    // MARK: - Variables
    
    /// The created date of the bundle
    public var dateCreated: String = ""
    /// The start date of the bundle
    public var startDate: String = ""
    /// The end date of the bundle
    public var endDate: String = ""
    /// Is the bundle rolling
    public var rolling: Bool = false
    /// Is the bundle enabled
    public var enabled: Bool = false
    /// It is possible for a data debit bundle to have an inner bundle object
    public var bundle: DataOfferRequiredDataDefinitionObjectV2 = DataOfferRequiredDataDefinitionObjectV2()
}
