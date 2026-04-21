import QtQuick
import QtQuick.Controls

Item {
    id: payerItem
    width: 330
    height: 124
    Label {
        id: payToLabel
        x: 8
        y: 23
        color: "#352828"
        text: qsTr("PAY TO")
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 20
    }
    
    Label {
        id: paymentModeLabel
        color: "#352828"
        text: qsTr("PAYMENT MODE")
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.bottomMargin: 20
    }
    
    ComboBox {
        id: payerComboBox
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 20
        anchors.topMargin: 20
        model: payersModel
        currentIndex: 0
        displayText: payerComboBox.currentText
    }
    
    ComboBox {
        id: paymentModeComboBox
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        model: ["Bank", "E-wallet", "Cash"]
    }
}
