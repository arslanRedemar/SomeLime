//
//  DIEnvironment.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/07.
//

import SwiftUI
import Swinject

private struct DIContainerKey: EnvironmentKey {
    static let defaultValue: Container = Container()
}

extension EnvironmentValues {
    var diContainer: Container {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
