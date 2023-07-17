//
//  StepCountWidgetBundle.swift
//  StepCountWidget
//
//  Created by 박진섭 on 2023/07/16.
//

import WidgetKit
import SwiftUI

@main
struct StepCountWidgetBundle: WidgetBundle {
    var body: some Widget {
        StepCountWidget()
        StepCountWidgetLiveActivity()
    }
}
