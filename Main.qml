import QtQuick 2.0
import Ubuntu.Components 1.1

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
        title: i18n.tr("planarity")

        Rectangle {
            id: board
            color: "white"
            anchors.fill: parent

            property var edges
            property int intersections

            function createGraph(vertLocs, edgePairs) {
                var vertex = Qt.createComponent("Vertex.qml")
                var verts = []
                for (var i=0; i<vertLocs.length; i++) {
                    var v = vertex.createObject(board, {"x": vertLocs[i][0], "y": vertLocs[i][1]})
                    verts.push(v)
                }

                edges = []
                var edge = Qt.createComponent("Edge.qml")
                for (var i=0; i<edgePairs.length; i++) {
                    var v1 = verts[edgePairs[i][0]],
                            v2 = verts[edgePairs[i][1]],
                            e = edge.createObject(board, {"v1": v1, "v2": v2})
                    edges.push(e)
                    v1.edges.push(e)
                    v2.edges.push(e)
                }
                countIntersections()
            }

            function intersect(e1, e2) {
                // Don't count intersections at vertices
                if (e1.v1 === e2.v1 || e1.v1 === e2.v2 || e1.v2 === e2.v1 || e1.v2 === e2.v2)
                    return false

                // Algorithm from http://stackoverflow.com/a/565282
                var a1 = e1.v1.x,
                        b1 = e1.v1.y,
                        c1 = e1.v2.x,
                        d1 = e1.v2.y,
                        a2 = e2.v1.x,
                        b2 = e2.v1.y,
                        c2 = e2.v2.x,
                        d2 = e2.v2.y,
                        denom = (c1 - a1) * (d2 - b2) - (c2 - a2) * (d1 - b1)
                if (denom == 0)
                    // Lines are parallel, or one isn't actually a line
                    return false
                var t1 = ((a2 - a1) * (d2 - b2) - (b2 - b1) * (c2 - a2)) / denom,
                        t2 = ((a2 - a1) * (d1 - b1) - (b2 - b1) * (c1 - a1)) /denom
                return (0 <= t1 && t1 <= 1 && 0 <= t2 && t2 <= 1)
            }

            function countIntersections() {
                intersections = 0
                var n = edges.length
                for (var i=0; i<n; i++)
                    for (var j=i+1; j<n; j++)
                        if (intersect(edges[i], edges[j]))
                            intersections += 1
            }

            function onVertexDragEnd() {
                countIntersections()
            }

            Component.onCompleted: createGraph([[0,0], [100,0], [0, 100], [100, 100]],
                                               [[0,1],[0,2],[0,3],[1,2],[1,3],[2,3]])

            Label {
                text: board.intersections
                anchors {
                    left: board.left
                    bottom: board.bottom
                }
            }
        }
    }
}

