//
//  PKConfiguration.swift
//  CUU
//
//  Created by Lara Marie Reimer on 27.01.19.
//

import Foundation

public protocol PKConfiguration {
    var storage: PKStorage { get }
    var interceptors: [IKInterceptor] { get }
}
