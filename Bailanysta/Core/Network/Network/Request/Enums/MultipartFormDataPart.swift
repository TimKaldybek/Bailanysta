//
//  MultipartFormDataPart.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 15.02.2021.
//

import Foundation

/// Одна часть данных для отправки в запросе multipart form.
///
/// Данные будут кодированы в запросе в таком формате:
/// Content-Disposition: form-data; name=#{name}; filename=#{filename} (HTTP Header)
/// Content-Type: #{mimeType} (HTTP Header)
/// Encoded file data
/// Multipart form boundary
public struct MultipartFormDataPart {
    public enum Source {
        case data(Data)
        case file(URL)
    }
    
    /// Источник данных для отправки в запросе
    public let source: Source
    
    /// Название части данных по договорённости с бэком. Отправляется в хедере Content-Disposition.
    /// Например, для одного аудиосообщения может быть "audio_message.m4a".
    /// Для массива картинок может быть "image[]".
    public let name: String

    /// Название файла. Отправляется в хедере Content-Disposition. Например, "image.jpg"
    public let fileName: String?

    /// Mime type. Отправляется в хедере Content-Type. Например, для jpeg-картинки будет "image/jpeg".
    public let mimeType: String?
    
    public init(data: Data, name: String, fileName: String? = nil, mimeType: MimeType? = nil) {
        self.init(source: .data(data), name: name, fileName: fileName, mimeType: mimeType)
    }
    
    /// Создаётся MultipartFormDataPart с source в виде data
    ///
    /// - Parameters:
    ///   - stringConvertible: Внутри переданный параметр сразу превращается в строку и кодируется в Data в формате utf8
    ///   - name: Название параметра
    public init(stringConvertible: LosslessStringConvertible, name: String) {
        self.init(source: .data(Data(stringConvertible.toString().utf8)), name: name, fileName: nil, mimeType: nil)
    }
    
    public init(source: Source, name: String, fileName: String? = nil, mimeType: MimeType? = nil) {
        self.source = source
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType?.rawValue
    }
}

public extension MultipartFormDataPart {
    static func makeArray(from dictionary: [String: LosslessStringConvertible]) -> [MultipartFormDataPart] {
        dictionary.map { Self(stringConvertible: $0.value, name: $0.key) }
    }
}

private extension LosslessStringConvertible {
    func toString() -> String {
        String(self)
    }
}
