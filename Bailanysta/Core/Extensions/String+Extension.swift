import Foundation

extension String {
    static var emptyString: String {
        ""
    }
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    var withoutWhitespaces: Self {
        components(separatedBy: .whitespaces).joined()
    }
    
    func separateName() -> String {
        guard !self.isEmpty, self.count > 1 else {
            return self
        }
        
        let words = self.split(separator: " ")
        
        return String(words[0])
    }
}

//MARK: - Date
extension String {
    func convertDate(to outputFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let outputDate = dateFormatter.date(from: self) else { return self }
        
        dateFormatter.dateFormat = outputFormat
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        return dateFormatter.string(from: outputDate)
    }
}
