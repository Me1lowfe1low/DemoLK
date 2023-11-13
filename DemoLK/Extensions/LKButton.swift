import SwiftUI

struct LKButton: View {
    
    let title: String
    let action: () -> Void
    
    var body: some View {
        
        Button(action: action,
               label: {
            Text(title.uppercased())
                .fontWeight(.bold)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
        )
        .background(Color.customRed)
        .cornerRadius(8)
    }
}
