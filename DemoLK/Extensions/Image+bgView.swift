import SwiftUI

extension Image {
    func bgView(
        geometry: GeometryProxy
    ) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color.customGray2)
            .frame(
                width: min(
                    geometry.size.width,
                    geometry.size.height
                ) * 0.3
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
    }
}
