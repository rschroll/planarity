/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file LICENSE for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1

import "database.js" as Database


Item {
    id: board
    width: parent.width
    height: parent.height

    property var edges
    property var vertices
    property int intersections
    property bool multiDrag: false

    function createGraph(vertLocs, edgePairs, fromDatabase) {
        // Destroy edges first, since they reference vertices
        for (var i in edges)
            edges[i].destroy()
        edges = []
        for (var i in vertices)
            vertices[i].destroy()
        vertices = []

        var vertex = Qt.createComponent("Vertex.qml")
        for (var i=0; i<vertLocs.length; i++) {
            var v = vertex.createObject(board, {"x": vertLocs[i][0], "y": vertLocs[i][1], "n": i})
            vertices.push(v)
        }

        var edge = Qt.createComponent("Edge.qml")
        for (var i=0; i<edgePairs.length; i++) {
            var v1 = vertices[edgePairs[i][0]],
                    v2 = vertices[edgePairs[i][1]],
                    e = edge.createObject(board, {"v1": v1, "v2": v2})
            edges.push(e)
            v1.edges.push(e)
            v2.edges.push(e)
        }
        countIntersections()
        if (!fromDatabase)
            Database.saveGraph(vertLocs, edgePairs)
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
        var ints = 0
        var n = edges.length
        for (var i=0; i<n; i++)
            for (var j=i+1; j<n; j++)
                if (intersect(edges[i], edges[j]))
                    ints += 1
        intersections = ints
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
                rad = Math.min(cx, cy) * 0.8
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

    function generate(n) {
        createGraph(circleVerts(n * (n - 1) / 2), generateGraph(n))
    }

    function reset() {
        for (var i in vertices)
            vertices[i].reset()
        recenterGraph()  // In case we've rotated the screen relative to the initial layout
        countIntersections()
    }

    function recenterGraph() {
        if (!vertices)
            return

        var minX = 1e6,
                maxX = 0,
                minY = 1e6,
                maxY = 0
        for (var i in vertices) {
            var v = vertices[i]
            if (v.x < minX)
                minX = v.x
            if (v.x > maxX)
                maxX = v.x
            if (v.y < minY)
                minY = v.y
            if (v.y > maxY)
                maxY = v.y
        }

        var oldWidth = (maxX - minX) / 0.8,  // Give a margin
                oldHeight = (maxY - minY) / 0.8,
                oldCenterX = (minX + maxX) / 2,
                oldCenterY = (minY + maxY) / 2,
                scale = Math.min(width / oldWidth, height / oldHeight)

        for (var i in vertices) {
            var v = vertices[i]
            v.x = (v.x - oldCenterX) * scale + width / 2
            v.y = (v.y - oldCenterY) * scale + height / 2
        }
    }

    function selectVertices() {
        var ctx = canvas.getContext("2d")
        for (var i in vertices) {
            var v = vertices[i]
            var img = ctx.getImageData(v.x, v.y, 2, 1)
            if (img.data[2] > 0)
                v.multiSelect = true
        }
    }

    function unselectVertices() {
        for (var i in vertices)
            vertices[i].multiSelect = false
    }

    function rescaleView() {
        // Move the vertices so we can reset the scale and the offset of the board
        var dx = x + width * (1 - scale) / 2,
                dy = y + height * (1 - scale) / 2
        for (var i in vertices) {
            var v = vertices[i]
            v.x = scale * v.x + dx
            v.y = scale * v.y + dy
        }
        scale = 1
        x = 0
        y = 0
    }

    onWidthChanged: layoutTimer.restart()

    Timer {
        id: layoutTimer
        interval: 200
        onTriggered: recenterGraph()
    }

    PinchArea {
        id: pinch
        anchors.fill: parent

        pinch {
            target: parent
            minimumScale: 0.1
            maximumScale: 10
            dragAxis: Pinch.XandYAxis
        }

        onPinchFinished: rescaleView()

        // Has to be a child of PinchArea for both to work...
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            property var points: []
            property var selectedVerts

            onPressed: {
                if (multiDrag) {
                    selectedVerts = []
                    for (var i in vertices)
                        if (vertices[i].multiSelect)
                            selectedVerts.push(vertices[i])
                    points = [mouse.x, mouse.y]
                } else {
                    unselectVertices()
                    points = [[mouse.x, mouse.y]]
                }
            }
            onPositionChanged: {
                if (multiDrag) {
                    var dx = mouse.x - points[0],
                            dy = mouse.y - points[1]
                    points = [mouse.x, mouse.y]
                    for (var i in selectedVerts) {
                        var v = selectedVerts[i]
                        v.x += dx
                        v.y += dy
                    }
                } else {
                    points.push([mouse.x, mouse.y])
                    canvas.requestPaint()
                }
            }
            onReleased: {
                if (multiDrag) {
                    multiDrag = false
                    countIntersections()
                    Database.updateVertices(selectedVerts)
                } else {
                    selectVertices()
                    points = []
                    canvas.requestPaint()
                }
            }
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = canvas.getContext("2d")
            ctx.fillStyle = "#400000ff"

            ctx.clearRect(0, 0, canvas.width, canvas.height)
            ctx.beginPath()
            for (var i in mouseArea.points)
                ctx.lineTo(mouseArea.points[i][0], mouseArea.points[i][1])
            ctx.fill()
        }
    }
}
