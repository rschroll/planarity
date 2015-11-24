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
            width: parent.width
            height: parent.height

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

            function findIntersect(x1, y1, dx1, dy1, x2, y2, dx2, dy2) {
                // Algorithm from http://stackoverflow.com/a/565282
                var denom = dx1 * dy2 - dx2 * dy1
                if (denom == 0)
                    //Lines are parallel, or one isn't actually a line
                    return []
                return [((x2 - x1) * dy2 - (y2 - y1) * dx2) / denom,
                        ((x2 - x1) * dy1 - (y2 - y1) * dx1) / denom]
            }

            function intersect(e1, e2) {
                // Don't count intersections at vertices
                if (e1.v1 === e2.v1 || e1.v1 === e2.v2 || e1.v2 === e2.v1 || e1.v2 === e2.v2)
                    return false

                var ints = findIntersect(e1.v1.x, e1.v1.y, e1.v2.x - e1.v1.x, e1.v2.y - e1.v1.y,
                                         e2.v1.x, e2.v1.y, e2.v2.x - e2.v1.x, e2.v2.y - e2.v1.y)
                if (ints.length != 2)
                    return false
                return (0 <= ints[0] && ints[0] <= 1 && 0 <= ints[1] && ints[1] <= 1)
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

            function generateGraph(n) {
                var origins = [],
                        dirs = [],
                        vertices = [],
                        k = 0;
                for (var i=0; i<n; i++) {
                    var x = Math.random(),
                            y = Math.random(),
                            q = Math.random() * 2 * Math.PI,
                            dx = Math.cos(q),
                            dy = Math.sin(q)
                    origins.push([x, y])
                    dirs.push([dx, dy])
                    vertices.push([])
                    for (var j=0; j<i; j++) {
                        var arclengths = findIntersect(x, y, dx, dy,
                                                       origins[j][0], origins[j][1], dirs[j][0], dirs[j][1])
                        vertices[i].push([arclengths[0], k])
                        vertices[j].push([arclengths[1], k])
                        k += 1
                    }
                }

                var edges = []
                for (var i=0; i<n; i++) {
                    var verts = vertices[i]
                    verts.sort(function (a,b) { return a[0] - b[0] })
                    for (var j=0; j<verts.length-1; j++)
                        edges.push([verts[j][1], verts[j+1][1]])
                }
                return edges
            }

            function circleVerts(n) {
                var verts = [],
                        cx = board.width/2,
                        cy = board.height/2,
                        rad = Math.min(cx, cy) * 0.5
                for (var i=0; i<n; i++) {
                    var q = 2 * Math.PI * i / n
                    verts.push([rad * Math.cos(q) + cx, rad * Math.sin(q) + cy])
                }

                // Shuffle from http://stackoverflow.com/a/12646864
                for (var i=n-1; i>0; i--) {
                    var j = Math.floor(Math.random() * (i + 1))
                    var temp = verts[i]
                    verts[i] = verts[j]
                    verts[j] = temp
                }

                return verts
            }

            Component.onCompleted: {
                var n = 10
                createGraph(circleVerts(n * (n - 1) / 2), generateGraph(n))
            }

            Label {
                text: board.intersections
                anchors {
                    left: board.left
                    bottom: board.bottom
                }
            }

            PinchArea {
                id: pinch
                anchors.fill: parent

                pinch {
                    target: parent
                    minimumScale: 1
                    maximumScale: 10
                    dragAxis: Pinch.XandYAxis
                    minimumX: width * (1 - parent.scale) / 2
                    maximumX: width * (parent.scale - 1) / 2
                    minimumY: height * (1 - parent.scale) / 2
                    maximumY: height * (parent.scale - 1) / 2
                }
            }
        }
    }
}

