import QtQuick 2.0
import Ubuntu.Components 1.1


Item {
    id: vertex

    property int size: units.gu(3)
    property var edges: []

    width: size
    height: size
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

    Rectangle {
        id: rect

        property int size: units.gu(2)

        width: size
        height: size
        radius: size/2
        x: (vertex.size - size) / 2
        y: (vertex.size - size) / 2
        color: "blue"
        border.color: "black"
        border.width: units.dp(1)
    }

    states: [
        State {
            name: "Selected"
            when: mouseArea.pressed
            PropertyChanges {
                target: rect
                color: "white"
            }
        },
        State {
            name: "Neighbor"
            PropertyChanges {
                target: rect
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
