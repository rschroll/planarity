import QtQuick 2.0
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Pickers 1.0

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "planarity.rschroll"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(100)
    height: units.gu(75)

    Page {
        id: mainPage

        property int headerHeight: units.gu(8)

        Rectangle {
            id: background
            anchors.fill: parent
            color: "white"
        }

        Rectangle {
            id: header
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: mainPage.headerHeight
            color: "white"
            clip: true
            z: 2

            FastBlur {
                id: blur
                source: boardContainer
                x: 0
                y: 0
                width: boardContainer.width
                height: boardContainer.height
                radius: 40
                visible: false
            }
            ColorOverlay {
                anchors.fill: blur
                source: blur
                color: "#80ffffff"
            }

            FloatingButton {
                anchors.left: parent.left
                buttons: [
                    Action {
                        iconName: "reload"
                        onTriggered: board.reset()
                    },
                    Action {
                        id: generateAction
                        iconName: board.intersections ? "media-playlist-shuffle" : "media-playback-start"
                        onTriggered: board.generate(orderPicker.selectedIndex + orderPicker.min)
                    }

                ]
            }

            Label {
                id: intersectionsLabel
                text: i18n.tr("%1 intersections").arg(board.intersections)
                anchors.centerIn: parent
                font.bold: true
                color: board.intersections ? Theme.palette.selected.backgroundText : UbuntuColors.green
            }

            Label {
                text: i18n.tr("Graph order")
                anchors {
                    right: orderPickerContainer.left
                    rightMargin: units.gu(1)
                    verticalCenter: orderPickerContainer.verticalCenter
                }
            }

            Item {
                id: orderPickerContainer
                anchors {
                    right: parent.right
                    rightMargin: units.gu(1)
                    top: parent.top
                    topMargin: units.gu(1)
                }
                width: units.gu(20)
                height: mainPage.headerHeight - units.gu(2)

                Picker {
                    id: orderPicker

                    property int min: 4
                    property int max: 15

                    anchors.centerIn: parent
                    height: parent.width
                    width: parent.height
                    rotation: -90
                    live: false
                    circular: false

                    delegate: PickerDelegate {
                        rotation: 90
                        Label {
                            text: modelData
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Component.onCompleted: {
                        var stack = []
                        for (var i=min; i<=max; i++)
                            stack.push(i)
                        model = stack
                        selectedIndex = 5
                    }
                }
            }
        }

        Item {
            id: boardContainer
            anchors.fill: parent

            Item {
                anchors {
                    fill: parent
                    topMargin: mainPage.headerHeight
                }
                z: 1

                Board {
                    id: board
                }
            }
        }

        // The Page gets resized several times during creation.  Hold off on
        // laying things out until this settles down.
        Timer {
            id: loadingTimer
            interval: 200

            onTriggered: generateAction.trigger()
        }
        onWidthChanged: loadingTimer.restart()
    }
}

