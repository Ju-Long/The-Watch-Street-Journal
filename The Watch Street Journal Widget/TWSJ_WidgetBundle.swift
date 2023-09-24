//
//  TWSJ_WidgetBundle.swift
//  The Watch Street Journal WidgetExtension
//
//  Created by BaBaSaMa on 24/9/23.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct The_Watch_Street_Jounral_WidgetBundle: WidgetBundle {
    var body: some Widget {
        LatestNewsWidget()
        TopicNewsWidget(topic: .business)
        TopicNewsWidget(topic: .entertainment)
        TopicNewsWidget(topic: .health)
        TopicNewsWidget(topic: .science)
        TopicNewsWidget(topic: .sports)
        TopicNewsWidget(topic: .technology)
        TopicNewsWidget(topic: .world)
    }
}
