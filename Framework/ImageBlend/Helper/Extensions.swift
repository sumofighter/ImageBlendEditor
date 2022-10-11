import UIKit

extension Bundle {
    static var this: Bundle {
        Bundle(for: ImageBlendModel.self)
    }
}
