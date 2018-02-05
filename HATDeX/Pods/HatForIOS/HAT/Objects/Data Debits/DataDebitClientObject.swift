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

public struct DataDebitClientObject: HATObject {
    
    // MARK: - Variables

    /// The user id of the client
    public var userId: String = ""
    /// The email of the client
    public var email: String = ""
    /// The pass of the client
    public var pass: String = ""
    /// The name of the client
    public var name: String = ""
    /// The role of the client
    public var role: String = ""
}
