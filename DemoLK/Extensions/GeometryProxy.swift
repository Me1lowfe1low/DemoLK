import SwiftUI

extension GeometryProxy {
    public var isTall: Bool {
        size.height > size.width
    }
    
    var isWide: Bool {
        size.width > size.height
    }
}
