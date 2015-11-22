import QtQuick 2.0
import Ubuntu.Components 1.1


Rectangle {
    id: vertex

    property int size: units.gu(2)
    property var edges: []

    width: size
    height: size
    radius: size/2
    color: "blue"
    border.color: "black"
    border.width: units.dp(1)
    z: 2

    MouseArea {
        id: mouseArea
        anchors.fill: vertex
        drag {
            target: vertex
            minimumX: 0
            minimumY: 0
            maximumX: board.width - vertex.size
            maximumY: board.height - vertex.size
        }

        drag.onActiveChanged: {
            if (!drag.active)
                board.onVertexDragEnd()
        }
    }

    states: [
        State {
            name: "Selected"
            when: mouseArea.pressed
            PropertyChanges {
                target: vertex
                color: "white"
            }
        },
        State {
            name: "Neighbor"
            PropertyChanges {
                target: vertex
                color: "red"
            }
        }
    ]

    transitions: [
        Transition {
            from: "Neighbor"
            to: ""
            ColorAnimation {
                duration: 1000
            }
        }
    ]
}
