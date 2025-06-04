//
//  ServerResponse.swift
//  Pawcus
//
//  Created by 김정원 on 6/4/25.
//

import Foundation

struct ServerResponse<T: Decodable>: Decodable {
    let isSuccess: Bool
    let code: String?
    let message: String?
    let data: T?
}
