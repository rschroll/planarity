import QtQuick 2.0
import Ubuntu.Components 1.1

Text {
    id: infoText
    width: parent.width
    textFormat: Text.RichText
    wrapMode: Text.Wrap
    color: Theme.palette.selected.backgroundText
    text: "<h1 align='center'>Planarity</h1><p>&nbsp;</p><p>" +
          i18n.tr("Untangle the graph: Drag the vertices to get rid of crossed lines. " +
                  "All graphs can be completely untangled, but it may take some time!") +
          "</p><p>" +
          i18n.tr("Vertices may be dragged individually, or you can draw a lasso around " +
                  "vertices to be moved together.  Two finger gestures pan and zoom the graph.") +
          "</p><p>" +
          i18n.tr("If your efforts have made things worse, use the reset button in the " +
                  "upper left to move things back to the start.  The shuffle button will "+
                  "generate a new puzzle.") +
          "</p><p>" +
          i18n.tr("The difficulty of the puzzle can be adjusted with the control in the " +
                  "upper right.  Note that the number of vertices scales with the square " +
                  "of the difficulty, so things get complicated quickly!") +
          "</p><p>" +
          i18n.tr("Original Flash game by %1.").arg("<a href='http://planarity.net/'>John Tantalo</a>") +
          "</p><p>" +
          i18n.tr("Based on gPlanarity by %1.").arg("<a href='http://web.mit.edu/xiphmont/Public/gPlanarity.html'>Monty</a>") +
          "</p><p>" +
          i18n.tr("This implentation &copy; 2015 by Robert Schroll and released under the GPL.") + "</p>"
    
    onLinkActivated: Qt.openUrlExternally(link)
}
