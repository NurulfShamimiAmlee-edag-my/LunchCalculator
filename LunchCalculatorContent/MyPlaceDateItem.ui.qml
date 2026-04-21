import QtQuick
import QtQuick.Controls

Item {
    id: placeDateItem
    width: 451
    height: 130
    Label {
        id: placeLabel
        color: "#322525"
        text: qsTr("PLACE")
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 20
    }
    
    Label {
        id: dateLabel
        y: 86
        color: "#322525"
        text: qsTr("DATE")
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.bottomMargin: 20
    }
    
    TextArea {
        id: textArea
        x: 134
        y: 78
        width: 235
        height: 32
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        placeholderText: qsTr("When did this transaction take place?")
    }
    
    TextArea {
        id: textArea1
        x: 134
        width: 235
        height: 32
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 20
        anchors.topMargin: 20
        placeholderText: qsTr("Where did you eat?")
    }
}
