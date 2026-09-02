//
//  MultipartFormData+MultipartFormDataPart.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 22.02.2021.
//

import Foundation
import Alamofire

extension MultipartFormData {
    func append(_ parts: [MultipartFormDataPart]) {
        parts.forEach(append)
    }
    
    private func append(_ part: MultipartFormDataPart) {
        switch part.source {
        case .data(let data):
            appendData(data, part: part)
        case .file(let fileUrl):
            appendFile(url: fileUrl, part: part)
        }
    }
    
    private func appendData(_ data: Data, part: MultipartFormDataPart) {
        append(data, withName: part.name, fileName: part.fileName, mimeType: part.mimeType)
    }
    
    private func appendFile(url: URL, part: MultipartFormDataPart) {
        if let fileName = part.fileName, let mimeType = part.mimeType {
            append(url, withName: part.name, fileName: fileName, mimeType: mimeType)
        } else {
            append(url, withName: part.name)
        }
    }
}
