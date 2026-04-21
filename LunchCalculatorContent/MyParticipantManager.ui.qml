import QtQuick
import QtQuick.Controls

Item {
    id: participantManager
    width: 200
    height: 200
    Button {
        id: addPersonBtn
        x: 16
        text: "Add Participant"
        // Position it next to your participants row
        anchors.left: participantsRow.right
        anchors.top: parent.top
        anchors.verticalCenter: participantsRow.verticalCenter
        anchors.leftMargin: 389
        anchors.topMargin: 20
        anchors.verticalCenterOffset: 178
        
        Connections {
            target: addPersonBtn
            function onClicked() {
                rectangle.peopleCount += 1
            }
        }
    }
    
    Button {
        id: deletePerson
        x: 16
        y: 101
        text: "Delete participant"
        anchors.verticalCenter: participantsRow.verticalCenter
        anchors.left: participantsRow.right
        anchors.top: addPersonBtn.bottom
        anchors.leftMargin: 389
        anchors.topMargin: 20
        enabled: rectangle.peopleCount > 1
        
        Connections {
            target: deletePerson
            function onClicked() {
                rectangle.peopleCount -= 1
            }
        }
        anchors.verticalCenterOffset: 239
    }
}
