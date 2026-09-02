//
//  Body.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 15.02.2021.
//

import Foundation

/// Enum для задания body в запросе
public enum Body {
    case parameters(Parameters)
    case multipartData([MultipartFormDataPart])
}
