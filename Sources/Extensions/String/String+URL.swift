//
//  String+URL.swift
//  CrowdSOLUTIONS
//
//  Created by Kevin Hoogheem on 8/17/23.
//  Copyright © 2023 AppCats LLC. All rights reserved.
//

import Foundation

extension String {
  
    /// URL from String
    ///
    /// - Returns: URL
    func toURL() -> URL? {
        guard !self.isBlankString else { return nil }
        
        if let url = URL(string: self.whitespaceTrimmed) {
            return url
        }
        
        guard let urlQueryAllowed = self.whitespaceTrimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: urlQueryAllowed)
    }

}

extension Optional where Wrapped == String {
   
    /// URL from String
    ///
    /// - Returns: URL
    func toURL() -> URL? {
        guard let self else { return nil }
        return self.toURL()
    }
    
}
