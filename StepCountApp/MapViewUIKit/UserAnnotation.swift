//
//  UserAnnotation.swift
//  StepCountApp
//
//  Created by 박진섭 on 2023/07/10.
//

import SwiftUI

struct UserAnnotation: View {
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(.orange)
            Circle()
                .foregroundStyle(.white)
                .padding(5)
        }
        .frame(width: 25, height: 25)
        .ignoresSafeArea()
    }
}

struct UserAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        UserAnnotation()
    }
}
