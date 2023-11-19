import SwiftUI

struct ParticipantLayout<Content: View>: View {
    let views: [AnyView]
    let spacing: CGFloat
    
    init<Data: RandomAccessCollection>(
        _ data: Data,
        id: KeyPath<Data.Element, Data.Element> = \.self,
        spacing: CGFloat,
        @ViewBuilder content: @escaping (Data.Element) -> Content) {
            self.spacing = spacing
            self.views = data.map { AnyView(content($0[keyPath: id])) }
        }
    
    var body: some View {
        GeometryReader { geometry in
            if views.isEmpty {
                EmptyView()
            } else if geometry.size.width <= 300 {
                grid(
                    axis: .vertical,
                    geometry: geometry
                )
            } else if geometry.size.height <= 300 {
                grid(
                    axis: .horizontal,
                    geometry: geometry
                )
            } else {
                let computedColumn = computeColumn(with: geometry)
                
                VStack(spacing: spacing) {
                    ForEach(0...(computedColumn.yVal - 1), id: \.self) { yValue in
                        HStack(spacing: spacing) {
                            ForEach(0...(computedColumn.xVal - 1), id: \.self) { xValue in
                                let index = (yValue * computedColumn.xVal) + xValue
                                if index < views.count {
                                    views[index]
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: -Private

extension ParticipantLayout {
    private func computeColumn(with geometry: GeometryProxy) -> (xVal: Int, yVal: Int) {
        let sqrt = Double(views.count).squareRoot()
        let result: [Int] = [Int(sqrt.rounded()), Int(sqrt.rounded(.up))]
        let column = geometry.isTall ? result : result.reversed()
        return (xVal: column[0], yVal: column[1])
    }
    
    private func grid(
        axis: Axis,
        geometry: GeometryProxy
    ) -> some View {
        ScrollView(
            [ axis == .vertical
              ? .vertical
              : .horizontal
            ]
        ) {
            AdaptiveGrid(
                axis: axis,
                columns: [GridItem(.flexible())],
                spacing: spacing
            ) {
                ForEach(0..<views.count, id: \.self) { i in
                    views[i]
                        .aspectRatio(1, contentMode: .fill)
                }
            }
            .padding(
                axis == .horizontal
                ? [.leading, .trailing]
                : [.top, .bottom],
                max(
                    0, ((axis == .horizontal ? geometry.size.width : geometry.size.height)
                        - ((axis == .horizontal ? geometry.size.height : geometry.size.width) * CGFloat(views.count)) - (spacing * CGFloat(views.count - 1))) / 2
                )
            )
        }
    }
}
