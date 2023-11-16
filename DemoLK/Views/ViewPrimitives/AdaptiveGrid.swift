import SwiftUI

struct AdaptiveGrid<Content: View>: View {
    let axis: Axis
    let spacing: CGFloat?
    let content: () -> Content
    let columns: [GridItem]
    
    init(
        axis: Axis = .horizontal,
        columns: [GridItem],
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.spacing = spacing
        self.columns = columns
        self.content = content
    }
    
    var body: some View {
        Group {
            if axis == .vertical {
                LazyVGrid(
                    columns: columns,
                    spacing: spacing,
                    content: content
                )
            } else {
                LazyHGrid(
                    rows: columns,
                    spacing: spacing,
                    content: content
                )
            }
        }
    }
}
