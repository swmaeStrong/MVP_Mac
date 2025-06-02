//
//  AppConfig.swift
//  MVP_MacOS
//
//  Created by 김정원 on 5/27/25.
//

import Foundation

enum AppConfig {
    static var baseURL: String {
        let domain = Bundle.main.infoDictionary?["BASE_DOMAIN"] as? String ?? ""
        return "http://\(domain)"
    }

    static var supabaseKey: String {
        return Bundle.main.infoDictionary?["SUPABASE_KEY"] as? String ?? ""
    }

    static var supabaseDomain: String {
        return Bundle.main.infoDictionary?["SUPABASE_DOMAIN"] as? String ?? ""
    }

    static var supabaseURL: String {
        return "https://\(supabaseDomain)"
    }
    
    static var redirectToURL = URL(string: "pawcus://login-callback")!
}
