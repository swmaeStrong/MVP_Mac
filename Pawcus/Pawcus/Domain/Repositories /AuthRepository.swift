//
//  AuthRepository.swift
//  Pawcus
//
//  Created by 김정원 on 6/1/25.
//

import Foundation

protocol AuthRepository {
    func loginWithGoogle() async -> Bool
}
