//
//  PSubscriptionContext.swift
//  Example
//
//  Created by Tomasz Lewandowski on 29/02/2020.
//  Copyright © 2020 LionSoftware.org. All rights reserved.
//

import Plug

protocol PSubscriptionContext: PRuleResolvingContext {
    var hasSubscription: Bool { get }
}
