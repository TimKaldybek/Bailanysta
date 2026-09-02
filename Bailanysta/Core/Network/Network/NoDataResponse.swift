//
//  NoDataResponse.swift
//  KolesaKz
//
//  Created by Beknar Danabek on 8/7/19.
//  Copyright © 2019 Kolesa LLC. All rights reserved.
//

private enum NoDataResponseStatus: String, Decodable {
    case ok
    case error
}

public struct NoDataResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case status
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(NoDataResponseStatus.self, forKey: CodingKeys.status)
        
        if status != .ok {
            throw NetworkError.incorrectFormat
        }
    }
}
