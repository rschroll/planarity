/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file LICENSE for full details.
 */

.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

function openDatabase() {
    return Sql.LocalStorage.openDatabaseSync("Settings", "1", "Settings for Planarity", 10000,
                                             onDatabaseCreated);
}

function clearGraph(tx) {
    tx.executeSql("DROP TABLE IF EXISTS Vertices");
    tx.executeSql("DROP TABLE IF EXISTS Edges");
    tx.executeSql("CREATE TABLE Vertices(id INT UNIQUE, x REAL, y REAL)");
    tx.executeSql("CREATE TABLE Edges(v1 INT, v2 INT)");
}

function onDatabaseCreated(db) {
    db.changeVersion(db.version, "1");
    db.transaction(function (tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS Settings(key TEXT UNIQUE, value TEXT)");
        clearGraph(tx);
    });
}

function getSetting(key, defaultValue) {
    var retval = defaultValue;
    openDatabase().readTransaction(function (tx) {
        var res = tx.executeSql("SELECT value FROM Settings WHERE key = ?", [key]);
        if (res.rows.length == 1)
            retval = res.rows.item(0).value;
    });
    return retval;
}

function setSetting(key, value) {
    openDatabase().transaction(function (tx) {
        tx.executeSql("INSERT OR REPLACE INTO Settings(key, value) VALUES(?, ?)", [key, value]);
    });
}

function saveGraph(verts, edges) {
    openDatabase().transaction(function (tx) {
        clearGraph(tx);
        for (var i in verts)
            tx.executeSql("INSERT INTO Vertices(id, x, y) VALUES(?, ?, ?)",
                          [i, verts[i][0], verts[i][1]]);
        for (var i in edges)
            tx.executeSql("INSERT INTO Edges(v1, v2) VALUES(?, ?)", edges[i]);
    });
}

function updateVertices(verts) {
    openDatabase().transaction(function (tx) {
        for (var i in verts) {
            var v = verts[i];
            tx.executeSql("UPDATE Vertices SET x = ?, y = ? WHERE id = ?", [v.x, v.y, v.n]);
        }
    });
}

function loadGraph(success, failure) {
    openDatabase().readTransaction(function (tx) {
        var verts = [], edges = [];
        var res = tx.executeSql("SELECT x, y FROM Vertices ORDER BY id");
        for (var i=0; i<res.rows.length; i++)
            verts.push([res.rows.item(i).x, res.rows.item(i).y]);
        res = tx.executeSql("SELECT v1, v2 FROM Edges");
        for (i=0; i<res.rows.length; i++)
            edges.push([res.rows.item(i).v1, res.rows.item(i).v2]);

        if (verts.length && edges.length)
            success(verts, edges, true);
        else
            failure();
    });
}
