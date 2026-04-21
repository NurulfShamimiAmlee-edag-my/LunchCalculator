

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 1920
    height: 1080

    Button {
        id: addItemButton
        x: 782
        y: 491
        text: qsTr("Add item")
        icon.color: "#ffffff"
    }

    Button {
        id: deleteItemButton
        x: 720
        y: 543
        width: 202
        height: 141
        text: qsTr("Delete item")
    }
}
