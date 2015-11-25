import QtQuick 2.0
import Ubuntu.Components 1.1

import "database.js" as Database


Item {
    id: vertex

    property double size: units.gu(3)
    property var edges: []
    property double originalX
    property double originalY
    property bool selected: mouseArea.pressed || multiSelect
    property bool multiSelect: false
    property int neighborCount: 0
    property int n

    width: size
    height: size
    z: 2
    scale: 1 / board.scale
    transform: Translate {
        x: -size / 2
        y: -size / 2
    }

    function saveLoc() {
        Database.updateVertex(n, x, y)
    }

    function reset() {
        x = originalX
        y = originalY
    }

    Component.onCompleted: {
        originalX = x
        originalY = y
    }

    MouseArea {
        id: mouseArea
        anchors.fill: vertex
        drag {
            target: multiSelect ? undefined : vertex
            threshold: 0
        }

        drag.onActiveChanged: {
            if (!drag.active) {
                saveLoc()
                board.onVertexDragEnd()
            }
        }

        onPressed: {
            if (!multiSelect) {
                board.unselectVertices()
            } else {
                board.multiDrag = true
                mouse.accepted = false
            }
        }
    }

    Rectangle {
        id: rect

        property double size: units.gu(2)

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
            when: selected
            PropertyChanges {
                target: rect
                color: "white"
            }
        },
        State {
            name: "Neighbor"
            when: neighborCount > 0 && !selected
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
