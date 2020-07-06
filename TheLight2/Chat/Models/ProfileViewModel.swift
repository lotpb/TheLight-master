//
//  ProfileViewModel.swift
//  TheLight2
//
//  Created by Peter Balsamo on 6/20/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
