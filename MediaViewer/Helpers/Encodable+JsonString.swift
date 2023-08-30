import Foundation

extension Encodable {
    func toJsonString() throws -> String {
        let data = try JSONEncoder.default.encode(self)
        return String(data: data, encoding: .utf8)!
    }
}
