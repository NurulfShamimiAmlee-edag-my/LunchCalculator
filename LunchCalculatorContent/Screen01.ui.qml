

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls
import LunchCalculator

Rectangle {
    id: rectangle
    width: Constants.width
    height: Constants.height
    color: "#8cae80"

    property int peopleCount: 5
    property var model

    MyPlaceDateItem {
        id: placeDateItem
        anchors.left: parent.left
        anchors.leftMargin: 20
        y: 20
    }

    MyPayerItem {
        id: payerItem
        anchors.left: parent.left
        anchors.leftMargin: 20
        y: 148
    }

    MySalesServiceTaxItem {
        id: salesServiceTaxItem
        anchors.left: parent.left
        anchors.leftMargin: 20
        y: 278
    }

    Item {
        id: headersItem
        y: 395
        width: 489
        height: 37
        anchors.left: parent.left
        anchors.leftMargin: 20

        Label {
            id: itemsLabel
            color: "#000000"
            text: qsTr("Items")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
        }

        Label {
            id: priceLabel
            x: 206
            color: "#000000"
            text: qsTr("Price")
            anchors.verticalCenter: parent.verticalCenter
        }

        Label {
            id: taxableLabel
            x: 357
            color: "#000000"
            text: qsTr("Taxable")
            anchors.verticalCenter: parent.verticalCenter
            anchors.top: parent.top
            anchors.topMargin: 7
        }
    }

    ScrollView {
        id: scrollView
        y: 422
        width: 1518
        height: 609
        anchors.left: parent.left
        anchors.leftMargin: 20

        Column {
            id: column
            width: 200
            height: 400

            Repeater {
                id: rowRepeater
                model: 20

                Item {
                    id: checkableFillableRow
                    width: 1194
                    height: 52

                    TextField {
                        id: itemsTxtField
                        x: 8
                        y: 8
                        width: 163
                        height: 32
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        placeholderText: qsTr("Text Field")
                    }

                    TextField {
                        id: priceTxtField
                        x: 211
                        y: 8
                        width: 125
                        height: 32
                        placeholderText: qsTr("Text Field")
                    }

                    ComboBox {
                        id: taxableComboBox
                        x: 368
                        y: 8
                        model: ["y", "n"]
                    }

                    Row {
                        id: checkBoxRow

                        x: 550
                        y: 8
                        spacing: 100

                        Repeater {
                            id: checkBoxRepeater
                            model: rectangle.peopleCount

                            CheckBox {
                                text: ""
                                checked: false
                            }
                        }
                    }
                }
            }
        }
    }

    Row {
        id: participantsRow
        x: 557
        y: 372
        width: 654
        height: 37
        spacing: 10

        Repeater {
            id: participantsRepeater
            model: rectangle.peopleCount

            ComboBox {
                id: participantsComboBox
                model: rectangle.model
            }
        }
    }

    MyOveralTotalItem {
        id: overalTotalItem
        x: 571
        y: 30
    }

    MyParticipantManager {
        id: participantManager
        anchors.left: participantsRow.right
        anchors.leftMargin: 373
        y: 513
    }

    states: [
        State {
            name: "clicked"
        }
    ]
}
