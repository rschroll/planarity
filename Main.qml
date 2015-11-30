/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file LICENSE for full details.
 */

import QtQuick 2.0
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Pickers 1.0

import "database.js" as Database

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

        Icon {
            id: tick
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height)
            height: width
            name: "tick"
            color: UbuntuColors.green
            opacity: 0
            visible: opacity > 0

            states: [
                State {
                    name: "Completed"
                    when: board.intersections == 0
                }
            ]
            transitions: [
                Transition {
                    from: ""
                    to: "Completed"
                    SequentialAnimation {
                        UbuntuNumberAnimation {
                            target: tick
                            property: "opacity"
                            from: 0
                            to: 1
                        }
                        UbuntuNumberAnimation {
                            target: tick
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: 2000
                        }
                    }
                }

            ]
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

            UbuntuShape {
                id: buttonContainer
                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    top: parent.top
                    topMargin: units.gu(1)
                    bottom: parent.bottom
                    bottomMargin: units.gu(1)
                }
                width: units.gu(20)
                color: "#0A000000"  // From PickerStyle.qml

                Row {
                    id: buttonRow
                    anchors.fill: parent

                    AbstractButton {
                        height: parent.height
                        width: parent.width / 3
                        action: Action {
                            iconName: "reload"
                            onTriggered: board.reset()
                        }

                        Icon {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                            }
                            height: parent.height/2
                            width: height
                            name: parent.iconName
                            opacity: parent.enabled ? 1.0 : 0.5
                        }
                    }

                    Rectangle {
                        color: UbuntuColors.warmGrey
                        height: parent.height
                        width: units.dp(1)
                    }

                    AbstractButton {
                        id: infoButton
                        height: parent.height
                        width: parent.width / 3 - units.dp(2)
                        action: Action {
                            iconName: "info"
                            onTriggered: infoDialog.visible = !infoDialog.visible
                        }

                        Icon {
                            id: infoIcon
                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                            }
                            height: parent.height/2
                            width: height
                            name: parent.iconName
                            opacity: parent.enabled ? 1.0 : 0.5
                        }
                    }

                    Rectangle {
                        color: UbuntuColors.warmGrey
                        height: parent.height
                        width: units.dp(1)
                    }

                    AbstractButton {
                        height: parent.height
                        width: parent.width / 3
                        action: Action {
                            id: generateAction
                            iconName: board.intersections ? "media-playlist-shuffle" : "media-playback-start"
                            onTriggered: board.generate(orderPicker.selectedIndex + orderPicker.min)
                        }
                        clip: true

                        Icon {
                            id: icon1
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                            }
                            y: parent.height / 4
                            height: parent.height / 2
                            width: height
                            name: "media-playlist-shuffle"
                        }

                        Icon {
                            id: icon2
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                            }
                            y: parent.height
                            height: parent.height/2
                            width: height
                            name: "media-playback-start"
                            color: UbuntuColors.green
                        }

                        states: [
                            State {
                                when: board.intersections == 0
                                PropertyChanges {
                                    target: icon1
                                    y: -parent.height / 2
                                }
                                PropertyChanges {
                                    target: icon2
                                    y: parent.height / 4
                                }
                            }
                        ]
                        transitions: [
                            Transition {
                                UbuntuNumberAnimation {
                                    target: icon1
                                    properties: "y"
                                }
                                UbuntuNumberAnimation {
                                    target: icon2
                                    properties: "y"
                                }
                            }
                        ]
                    }
                }
            }

            Label {
                id: intersectionsLabel
                text: i18n.tr("%1 intersection", "%1 intersections", board.intersections).arg(board.intersections)
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    topMargin: units.gu(1)
                    leftMargin: units.gu(1)
                }
                font.bold: true
                color: board.intersections ? Theme.palette.selected.backgroundText : UbuntuColors.green
            }

            Label {
                id: difficultyLabel
                text: i18n.tr("Difficulty")
                anchors {
                    top: parent.top
                    topMargin: units.gu(1)
                    horizontalCenter: orderPickerContainer.horizontalCenter
                }
            }

            Item {
                id: orderPickerContainer
                anchors {
                    right: parent.right
                    rightMargin: units.gu(1)
                    top: difficultyLabel.bottom
                    bottom: parent.bottom
                    bottomMargin: units.gu(1)
                }
                width: units.gu(20)

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

                    onSelectedIndexChanged: Database.setSetting("difficulty", selectedIndex)

                    Component.onCompleted: {
                        var stack = []
                        for (var i=min; i<=max; i++)
                            stack.push(i)
                        model = stack
                        selectedIndex = Database.getSetting("difficulty", 0)
                    }
                }
            }

            states: [
                State {
                    when: width < units.gu(60)
                    AnchorChanges {
                        target: intersectionsLabel
                        anchors.top: parent.top
                        anchors.horizontalCenter: buttonContainer.horizontalCenter
                        anchors.verticalCenter: undefined
                    }
                    AnchorChanges {
                        target: buttonContainer
                        anchors.top: intersectionsLabel.bottom
                    }
                    PropertyChanges {
                        target: buttonContainer
                        anchors.topMargin: 0
                    }
                }
            ]
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

        Item {
            id: infoDialog
            visible: false
            anchors.fill: parent
            height: units.gu(100)
            z: 3

            Flickable {
                id: infoFlickable
                anchors.centerIn: parent
                width: Math.min(parent.width, units.gu(60))
                height: Math.min(parent.height - 2 * mainPage.headerHeight, infoText.paintedHeight)
                contentHeight: infoText.paintedHeight
                clip: true

                InfoText {
                    id: infoText
                }
            }

            Button {
                anchors {
                    top: infoFlickable.bottom
                    topMargin: units.gu(1)
                    horizontalCenter: parent.horizontalCenter
                }
                width: units.gu(20)
                height: mainPage.headerHeight - units.gu(2)
                color: "#40d9d9d9"    // To match header button over white, but be dark enough to
                text: i18n.tr("Play") // force the Button to use dark text.

                onClicked: infoDialog.visible = false
            }

            onVisibleChanged: Database.setSetting("showInfo", visible)
        }

        states: [
            State {
                when: infoDialog.visible
                PropertyChanges {
                    target: header
                    clip: false
                }
                PropertyChanges {
                    target: boardContainer
                    visible: false
                }
                PropertyChanges {
                    target: infoIcon
                    color: UbuntuColors.orange
                }
            }
        ]

        Component.onCompleted: {
            infoDialog.visible = (Database.getSetting("showInfo", true) != 0)
            Database.loadGraph(board.createGraph, generateAction.trigger)
        }
    }
}

