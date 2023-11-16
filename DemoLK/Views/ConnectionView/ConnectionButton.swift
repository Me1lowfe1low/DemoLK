import SwiftUI

struct ConnectionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        
        Button(
            action: action,
            label: {
                Text(title.uppercased())
                    .fontWeight(.bold)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, verticalPadding)
            }
        )
        .background(.red)
        .cornerRadius(borderRadius)
    }
}

private let horizontalPadding: CGFloat = 12.0
private let verticalPadding: CGFloat = 10.0
private let borderRadius: CGFloat = 8.0

#if DEBUG
#Preview {
    ConnectionButton(title: "Test Button") {}
}
#endif
