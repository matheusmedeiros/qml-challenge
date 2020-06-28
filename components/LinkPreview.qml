import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12

Component {
    id: linkPreview;

    Rectangle {
        required property string title;
        required property string time;
        required property string by;
        required property int descendants;
        required property int score;
        required property url url;

        readonly property string commentsLabel: descendants > 1 ? "comments" : "comment";
        readonly property string upvotesLabel: score > 1 ? "upvotes" : "upvote";

        readonly property string details: `${time} by <strong>${by}</strong> | ${descendants} ${commentsLabel} | ${score} upvotesLabel`

        width: parent.width;
        height: 40;
        color: mouseArea.containsMouse ? "lightsteelblue" : "white";

        Column {
            Text {
                text: title;
                font.bold: true;
                topPadding: 1;
                bottomPadding: 1;
                leftPadding: 5;
                rightPadding: 2;
            }

            Text {
                text: details;
                topPadding: 1;
                bottomPadding: 1;
                leftPadding: 5;
            }
        }

        MouseArea {
            id: mouseArea;
            anchors.fill: parent;
            hoverEnabled: true;
            cursorShape: Qt.PointingHandCursor;
            onClicked: Qt.openUrlExternally(url);
        }
    }
}

