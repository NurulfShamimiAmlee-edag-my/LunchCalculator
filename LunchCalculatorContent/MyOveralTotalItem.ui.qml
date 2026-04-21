import QtQuick
import QtQuick.Controls

Item {
    id: overalTotalItem
    width: 392
    height: 114
    
    Label {
        id: subTotalLabel
        x: 15
        y: 17
        color: "#322525"
        text: qsTr("SUBTOTAL (RM)")
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 20
    }
    
    Label {
        id: servChargeTotalLabel
        x: 15
        y: 45
        color: "#322525"
        text: qsTr("SERV. CHARGE TOTAL (RM)")
        anchors.left: parent.left
        anchors.leftMargin: 20
    }
    
    Label {
        id: sstTotalLabel
        x: 15
        color: "#322525"
        text: qsTr("SST TOTAL (RM)")
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.bottomMargin: 20
    }
    
    Text {
        id: priceTotal
        y: 14
        width: 110
        height: 23
        text: qsTr("Text")
        anchors.right: parent.right
        anchors.rightMargin: 20
        font.pixelSize: 17
    }
    
    Text {
        id: servChargeTotal
        y: 45
        width: 110
        height: 23
        text: qsTr("Text")
        anchors.right: parent.right
        anchors.rightMargin: 20
        font.pixelSize: 17
    }
    
    Text {
        id: sstTotal
        width: 110
        height: 23
        text: qsTr("Text")
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        font.pixelSize: 17
    }
}
