//
//  ItemDocumentView.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 18.09.2025.
//

import SwiftUI
import UIKit

struct ItemDocumentView: View {
    
    var image: UIImage
    var name: String
    var creationDate: String
    var format: String = ".pdf"
    
    var body: some View {
        HStack(spacing: 16) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(creationDate)\(format)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ItemDocumentView(
        image: UIImage(systemName: "doc.fill")!,
        name: "Важный документ",
        creationDate: "10.03.2025-10:03:09"
    )
}
