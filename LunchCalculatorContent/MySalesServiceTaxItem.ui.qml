import QtQuick
import QtQuick.Controls

Item {
    id: salesServiceTaxItem
    width: 339
    height: 111
    TextField {
        id: sstTxtField
        x: 192
        y: 59
        width: 111
        height: 32
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 36
        anchors.bottomMargin: 20
        placeholderText: qsTr("Text Field")
    }
    
    TextField {
        id: serviceChargeTxtField
        x: 192
        width: 111
        height: 32
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 36
        anchors.topMargin: 20
        placeholderText: qsTr("Text Field")
    }
    
    Label {
        id: sstLabel
        color: "#3d3030"
        text: qsTr("SST  (%)")
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.bottomMargin: 20
    }
    
    Label {
        id: serviceChargeLabel
        color: "#3d3030"
        text: qsTr("SERVICE CHARGE (%)")
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 20
    }
}
