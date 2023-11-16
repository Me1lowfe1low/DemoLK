import SwiftUI

extension Image {
    func backgroundIcon(
        geometry: GeometryProxy
    ) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(imageColor)
            .frame(
                width: min(
                    geometry.size.width,
                    geometry.size.height
                ) * imageSizingCoefficient
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
    }
}

private let imageSizingCoefficient: CGFloat = 0.3
private let imageColor: Color = .gray

#if DEBUG
#Preview {
    GeometryReader { geometry in
        Image(systemName: "paperplane.fill").backgroundIcon(geometry: geometry)
    }
}
#endif
