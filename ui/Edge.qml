/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file LICENSE for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1


Rectangle {
    id: edge
    
    property var v1
    property var v2
    
    width: Math.sqrt((v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y))
    height: units.dp(2) / board.scale
    x: v1.x
    y: v1.y - height/2
    z: 1
    color: "#aaaaaa"
    transform: Rotation {
        origin.x: 0
        origin.y: edge.height/2
        angle: Math.atan2(edge.v2.y - edge.v1.y, edge.v2.x - edge.v1.x) * 180 / Math.PI
    }

    Connections {
        target: v1
        onSelectedChanged: {
            if (v1.selected)
                v2.neighborCount += 1
            else
                v2.neighborCount -= 1
        }
    }

    Connections {
        target: v2
        onSelectedChanged: {
            if (v2.selected)
                v1.neighborCount += 1
            else
                v1.neighborCount -= 1
        }
    }

    states: [
        State {
            name: "Selected"
            when: (v1.state == "Selected" || v2.state == "Selected") && v1.state != v2.state
            PropertyChanges {
                target: edge
                color: "black"
            }
        }
    ]

    transitions: [
        Transition {
            to: ""
            ColorAnimation {
                duration: 1000
            }
        }
    ]
}
