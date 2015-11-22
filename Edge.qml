import QtQuick 2.0
import Ubuntu.Components 1.1


Rectangle {
    id: edge
    
    property var v1
    property var v2
    
    width: Math.sqrt((v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y))
    height: units.dp(2)
    x: v1.x + v1.size/2
    y: v1.y + v1.size/2 - height/2
    z: 1
    color: "#aaaaaa"
    transform: Rotation {
        origin.x: 0
        origin.y: edge.height/2
        angle: Math.atan2(edge.v2.y - edge.v1.y, edge.v2.x - edge.v1.x) * 180 / Math.PI
    }

    states: [
        State {
            name: "Selected1"
            when: v1.state == "Selected"
            PropertyChanges {
                target: edge
                color: "black"
            }
            PropertyChanges {
                target: v2
                state: "Neighbor"
            }
        },
        State {
            name: "Selected2"
            when: v2.state == "Selected"
            PropertyChanges {
                target: edge
                color: "black"
            }
            PropertyChanges {
                target: v1
                state: "Neighbor"
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
