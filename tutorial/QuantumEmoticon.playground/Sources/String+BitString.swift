import Foundation

public extension String {
    init(bitSubstring: Substring) {
        self.init(bitstring: String(bitSubstring))
    }

    init(bitstring: String) {
        let asciiInt = UInt8(strtoul(bitstring, nil, 2))
        let scalar = UnicodeScalar(asciiInt)
        let char = Character(scalar)

        self.init(char)
    }
}
