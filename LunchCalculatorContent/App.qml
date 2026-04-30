import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Qt.labs.settings

// ---------------------------------------------------------------------------
//  Main.qml  –  Lunch Calculator
//
//  Layout mirrors the Excel sheet:
//    ┌─ Header (place / date / payTo / service% / SST%) ───────────────────┐
//    ├─ Item table  (TableView backed by LunchModel) ──────────────────────┤
//    │   Col 0: Item name  |  Col 1: Price  |  Col 2: Tax?  |  Col N: Person│
//    ├─ Bill summary  (subtotal / service charge / SST / grand total) ──────┤
//    └─ Per-person totals row ──────────────────────────────────────────────┘
// ---------------------------------------------------------------------------

ApplicationWindow {
    id: root
    visible: true
    width: 900
    height: 700
    title: "Lunch Calculator"

    // ── Colour palette ──────────────────────────────────────────────────
    readonly property color colHeader:     "#1a3a5c"   // dark blue (Excel header)
    readonly property color colHeaderText: "white"
    readonly property color colOrange:     "#c85a00"   // "Pay To" orange
    readonly property color colYellow:     "#ffff00"   // input highlight
    readonly property color colSubtotal:   "#d0d0d0"   // grey rows
    readonly property color colPersonTot:  "#1a3a5c"   // same as header
    readonly property color colAlt:        "#eef2f7"   // alternating row tint

    // Row index that should grab focus as soon as its delegate is created.
    // Set before addItem(); cleared by the delegate itself once focused.
    property int  autoFocusRow:  -1
    property bool showDetails:   false

    // ── Helpers ─────────────────────────────────────────────────────────
    function fmt(n) { return "MYR " + n.toFixed(2) }

    // ── Shared names list (edit PersonNames.qml to change) ───────────────
    PersonNames { id: personNames }

    // Persist the names list across sessions via the system registry.
    Settings {
        id: appSettings
        category: "NamesManager"
        property string namesJson: ""   // empty = first run, fall back to PersonNames.qml
    }

    // Runtime names list — initialized from saved settings or the default file.
    property var sessionNames: appSettings.namesJson !== ""
                               ? JSON.parse(appSettings.namesJson)
                               : personNames.names.slice()

    onSessionNamesChanged: appSettings.namesJson = JSON.stringify(sessionNames)

    // ── Root layout ─────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // ================================================================
        //  1. HEADER SECTION
        // ================================================================
        GridLayout {
            columns: 4
            columnSpacing: 6
            rowSpacing: 4
            Layout.fillWidth: true

            // Row 0 – Place
            Label { text: "PLACE"; font.bold: true }
            TextField {
                id: placeField
                text: calculator.place
                Layout.fillWidth: true
                Layout.columnSpan: 3
                onTextChanged: calculator.place = text
            }

            // Row 1 – Date
            Label { text: "DATE"; font.bold: true }
            TextField {
                id: dateField
                text: calculator.date
                Layout.fillWidth: true
                Layout.columnSpan: 3
                onTextChanged: calculator.date = text
            }

            // Row 2 – Pay To
            Rectangle {
                color: colOrange
                radius: 2
                Layout.fillWidth: true
                height: payToLabel.implicitHeight + 8
                Label { id: payToLabel; anchors.centerIn: parent; text: "Pay To"; color: "white"; font.bold: true }
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.columnSpan: 3
                spacing: 2
                TextField {
                    id: payToField
                    text: calculator.payTo
                    Layout.fillWidth: true
                    background: Rectangle { color: colOrange; radius: 2 }
                    color: "white"
                    font.bold: true
                    onTextChanged: calculator.payTo = text
                }
                Button {
                    implicitWidth: 28
                    implicitHeight: payToField.implicitHeight
                    background: Rectangle { color: Qt.darker(colOrange, 1.15); radius: 2 }
                    contentItem: Label {
                        text: "▼"; color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: payToMenu.open()
                    Menu {
                        id: payToMenu
                        Repeater {
                            model: sessionNames
                            MenuItem {
                                text: modelData
                                onTriggered: payToField.text = modelData
                            }
                        }
                    }
                }
            }

            // Row 3 – Service Charge %
            Label { text: "Service Charge %" }
            TextField {
                id: serviceChargeField
                text: calculator.serviceChargePct.toFixed(0) + "%"
                background: Rectangle { color: colYellow }
                Layout.fillWidth: true
                onEditingFinished: {
                    var v = parseFloat(text.replace("%",""));
                    if (!isNaN(v)) calculator.serviceChargePct = v;
                }
            }
            Item { Layout.columnSpan: 2; Layout.fillWidth: true }

            // Row 4 – SST %
            Label { text: "SST %" }
            TextField {
                id: sstField
                text: calculator.sstPct.toFixed(0) + "%"
                background: Rectangle { color: colYellow }
                Layout.fillWidth: true
                onEditingFinished: {
                    var v = parseFloat(text.replace("%",""));
                    if (!isNaN(v)) calculator.sstPct = v;
                }
            }
            Item { Layout.columnSpan: 2; Layout.fillWidth: true }
        }

        // ── Person management toolbar ────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Label { text: "Persons:"; font.bold: true }
            Repeater {
                model: calculator.persons
                RowLayout {
                    spacing: 2
                    Label { text: modelData }
                    Button {
                        text: "✕"
                        flat: true
                        implicitWidth: 20; implicitHeight: 20
                        onClicked: calculator.removePerson(index)
                    }
                }
            }
            Button {
                text: "+ Add Person"
                onClicked: addPersonDialog.open()
            }
            Button {
                text: "⚙"
                ToolTip.visible: hovered
                ToolTip.text: "Manage names list"
                onClicked: manageNamesDialog.open()
            }
        }

        // ================================================================
        //  2. ITEM TABLE
        //     Qt 6 TableView with HorizontalHeaderView + VerticalHeaderView
        // ================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: "#aaa"
            clip: true

            // ── Top-left corner fill (sits behind both header views) ─────
            Rectangle {
                id: cornerFill
                width: rowDeleteHeader.width
                height: tableHeader.height
                color: colHeader
            }

            // ── Row delete buttons (vertical header) ─────────────────────
            VerticalHeaderView {
                id: rowDeleteHeader
                syncView: tableBody
                anchors { top: cornerFill.bottom; left: parent.left; bottom: parent.bottom }
                width: 28

                delegate: Button {
                    required property int row   // 0-based section index, always reliable
                    implicitWidth: 28
                    implicitHeight: 28
                    text: "✕"
                    flat: true
                    font.pixelSize: 10
                    background: Rectangle {
                        color: hovered ? "#fdd" : (row % 2 === 0 ? "white" : colAlt)
                        border.color: "#ddd"
                    }
                    onClicked: calculator.removeItem(row)
                }
            }

            HorizontalHeaderView {
                id: tableHeader
                syncView: tableBody
                anchors { top: parent.top; left: rowDeleteHeader.right; right: parent.right }
                height: 30

                delegate: Rectangle {
                    color: colHeader
                    border.color: "#334"

                    readonly property bool isSelectAll: display === "SC?" || display === "SST?"

                    Label {
                        anchors.centerIn: parent
                        visible: !parent.isSelectAll
                        text: display
                        color: colHeaderText
                        font.bold: true
                        font.pixelSize: 11
                    }

                    Row {
                        anchors.centerIn: parent
                        visible: parent.isSelectAll
                        spacing: 3

                        Rectangle {
                            width: 13; height: 13
                            anchors.verticalCenter: parent.verticalCenter
                            border.color: "white"; border.width: 1; radius: 2
                            color: "transparent"
                            Rectangle {
                                anchors.centerIn: parent
                                width: 7; height: 7; radius: 1
                                color: "white"
                                visible: display === "SC?" ? calculator.allSC : calculator.allSST
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (display === "SC?")
                                        calculator.model.setAllSC(!calculator.allSC)
                                    else
                                        calculator.model.setAllSST(!calculator.allSST)
                                }
                            }
                        }

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: display
                            color: colHeaderText
                            font.bold: true
                            font.pixelSize: 11
                        }
                    }
                }
            }

            TableView {
                id: tableBody
                anchors {
                    top: tableHeader.bottom
                    left: rowDeleteHeader.right; right: parent.right; bottom: parent.bottom
                }
                model: calculator.model
                clip: true
                reuseItems: false

                columnWidthProvider: function(col) {
                    if (col === 0) return 180   // name
                    if (col === 1) return 55    // qty
                    if (col === 2) return 100   // unit price
                    if (col === 3) return 50    // SC?
                    if (col === 4) return 50    // SST?
                    if (col === 5) return showDetails ? 80  : 0   // split count
                    if (col === 6) return showDetails ? 110 : 0   // cost per person
                    return 80                   // person columns
                }
                rowHeightProvider: function() { return 28 }

                delegate: Item {
                    id: cellDelegate
                    implicitWidth: tableBody.columnWidthProvider(column)
                    implicitHeight: 28

                    required property int    row
                    required property int    column
                    required property var    display
                    property Item editField: null   // registered by textCell on load

                    Rectangle {
                        anchors.fill: parent
                        color: cellDelegate.row % 2 === 0 ? "white" : colAlt
                        border.color: "#ddd"
                    }

                    Loader {
                        anchors.fill: parent
                        anchors.margins: 2

                        sourceComponent: {
                            if (cellDelegate.column === 0 || cellDelegate.column === 1 || cellDelegate.column === 2) return textCell
                            if (cellDelegate.column === 5 || cellDelegate.column === 6) return readOnlyCell
                            return checkCell
                        }
                    }

                    Component {
                        id: textCell
                        TextField {
                            id: cellTf
                            font.pixelSize: 12
                            background: Item {}
                            verticalAlignment: Text.AlignVCenter

                            Component.onCompleted: {
                                cellDelegate.editField = this
                                if (root.autoFocusRow === cellDelegate.row && cellDelegate.column === 0) {
                                    forceActiveFocus()
                                    root.autoFocusRow = -1
                                }
                            }

                            Keys.onReturnPressed: {
                                var rowCount = calculator.model.rowCount()
                                if (cellDelegate.row < rowCount - 1) {
                                    var nextCell = tableBody.itemAtCell(0, cellDelegate.row + 1)
                                    if (nextCell && nextCell.editField)
                                        nextCell.editField.forceActiveFocus()
                                } else {
                                    root.autoFocusRow = rowCount
                                    calculator.addItem()
                                }
                            }

                            // Keep text in sync with the model whenever this field
                            // is not focused. When the user is typing, the binding
                            // suspends so keystrokes aren't overwritten. Because we
                            // commit on every keystroke (onTextChanged below), the
                            // model always holds the latest value — so whenever focus
                            // is lost (or the delegate is rebuilt), text snaps back to
                            // whatever the model says, which is exactly what was typed.
                            Binding {
                                target: cellTf
                                property: "text"
                                value: cellDelegate.column === 2
                                       ? (cellDelegate.display ?? 0).toFixed(2)
                                       : (cellDelegate.display ?? "").toString()
                                when: !cellTf.activeFocus
                                restoreMode: Binding.RestoreNone
                            }

                            onTextChanged: {
                                if (activeFocus) {
                                    let idx = calculator.model.index(cellDelegate.row, cellDelegate.column)
                                    calculator.model.setData(idx, text, Qt.EditRole)
                                }
                            }
                            onEditingFinished: {
                                let idx = calculator.model.index(cellDelegate.row, cellDelegate.column)
                                calculator.model.setData(idx, text, Qt.EditRole)
                            }
                        }
                    }

                    Component {
                        id: checkCell
                        CheckBox {
                            anchors.centerIn: parent
                            checked: cellDelegate.display === true || cellDelegate.display === "true"
                            onToggled: {
                                let idx = calculator.model.index(cellDelegate.row, cellDelegate.column)
                                calculator.model.setData(idx, checked, Qt.EditRole)
                            }
                        }
                    }

                    Component {
                        id: readOnlyCell
                        Label {
                            anchors.centerIn: parent
                            text: cellDelegate.column === 5
                                  ? (cellDelegate.display ?? 0).toString()
                                  : (cellDelegate.display ?? 0).toFixed(2)
                            font.pixelSize: 12
                            color: "#555"
                        }
                    }
                }
            }
        }

        // ── Item toolbar ─────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "+ Add Item"
                onClicked: calculator.addItem()
            }
            Button {
                text: showDetails ? "Hide Details" : "Show Details"
                onClicked: {
                    showDetails = !showDetails
                    tableBody.forceLayout()
                }
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Copy to Clipboard"
                onClicked: imageExporter.grabAndCopy(root.contentItem)
            }
            Button {
                text: "Save as PNG"
                onClicked: imageExporter.grabAndSave(
                    root.contentItem,
                    imageExporter.defaultSavePath(calculator.place, calculator.date))
            }
            Button {
                text: "New Bill"
                onClicked: {
                    calculator.reset()
                    placeField.text       = ""
                    dateField.text        = calculator.date
                    payToField.text       = ""
                    serviceChargeField.text = calculator.serviceChargePct.toFixed(0) + "%"
                    sstField.text         = calculator.sstPct.toFixed(0) + "%"
                    receiptAmtField.text  = "0.00"
                }
            }
        }

        // ================================================================
        //  3. BILL SUMMARY  (subtotal / service charge / SST / grand total)
        // ================================================================
        GridLayout {
            columns: 2
            columnSpacing: 12
            rowSpacing: 2
            Layout.fillWidth: true

            // ── Helper component: a standard read-only summary row ────────
            component SummaryRow : RowLayout {
                property string label: ""
                property double value: 0.0
                Layout.columnSpan: 2
                Layout.fillWidth: true
                Rectangle {
                    color: colSubtotal; width: 160; height: 22
                    Label { anchors.centerIn: parent; text: parent.parent.label; font.bold: true; font.pixelSize: 11 }
                }
                Rectangle {
                    color: colSubtotal; width: 100; height: 22
                    Label { anchors.centerIn: parent; text: fmt(parent.parent.value); font.pixelSize: 11 }
                }
                Item { Layout.fillWidth: true }
            }

            SummaryRow { label: "SUBTOTAL";     value: calculator.subtotal      }
            SummaryRow { label: "Serv. Charge"; value: calculator.serviceCharge }
            SummaryRow { label: "SST";          value: calculator.sst           }
            SummaryRow { label: "GRAND TOTAL";  value: calculator.grandTotal    }

            // ── Receipt Amt row — user enters actual amount from receipt ──
            RowLayout {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                Rectangle {
                    color: colSubtotal; width: 160; height: 22
                    Label { anchors.centerIn: parent; text: "RECEIPT AMT"; font.bold: true; font.pixelSize: 11 }
                }
                TextField {
                    id: receiptAmtField
                    width: 100; height: 22
                    text: calculator.receiptAmt.toFixed(2)
                    background: Rectangle { color: colYellow }
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignRight
                    onEditingFinished: {
                        var v = parseFloat(text)
                        if (!isNaN(v)) calculator.receiptAmt = v
                    }
                }
                Item { Layout.fillWidth: true }
            }

            // ── Difference row — auto-calculated, red if negative ─────────
            RowLayout {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                Rectangle {
                    color: colSubtotal; width: 160; height: 22
                    Label { anchors.centerIn: parent; text: "DIFFERENCE"; font.bold: true; font.pixelSize: 11 }
                }
                Rectangle {
                    color: colSubtotal; width: 100; height: 22
                    Label {
                        anchors.centerIn: parent
                        text: fmt(calculator.difference)
                        font.pixelSize: 11
                        color: calculator.difference < -0.001 ? "red"
                             : calculator.difference >  0.001 ? "green"
                             : "black"
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }

        // ================================================================
        //  4. PER-PERSON TOTALS
        // ================================================================
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: colPersonTot
            radius: 3
            clip: true

            ScrollView {
                anchors { fill: parent; margins: 4 }
                contentWidth: personTotalsRow.implicitWidth
                ScrollBar.vertical.policy:   ScrollBar.AlwaysOff
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded

                Row {
                    id: personTotalsRow
                    spacing: 16

                    Label { text: "Per Person:"; color: "white"; font.bold: true; font.pixelSize: 11 }

                    Repeater {
                        model: calculator.personTotals
                        Column {
                            spacing: 1
                            Label { text: modelData.name;  color: "white"; font.bold: true;  font.pixelSize: 11 }
                            Label { text: "Food: "     + fmt(modelData.food);                              color: "#cde"; font.pixelSize: 10 }
                            Label { text: "SC+SST: "   + fmt(modelData.serviceCharge + modelData.tax);    color: "#cde"; font.pixelSize: 10 }
                            Label { text: fmt(modelData.total); color: colYellow; font.bold: true; font.pixelSize: 12 }
                        }
                    }
                }
            }
        }

    } // end ColumnLayout

    // ── Toast notification for share actions ─────────────────────────────
    Popup {
        id: shareToast
        property string message: ""
        anchors.centerIn: Overlay.overlay
        padding: 12
        modal: false
        closePolicy: Popup.NoAutoClose

        background: Rectangle { color: "#222"; radius: 6 }
        Label { text: shareToast.message; color: "white"; font.pixelSize: 12 }

        Timer {
            interval: 2500
            running: shareToast.visible
            onTriggered: shareToast.close()
        }

        function show(msg) { message = msg; open() }
    }

    Connections {
        target: imageExporter
        function onCopyDone()     { shareToast.show("Copied to clipboard!") }
        function onSaveDone(path) { shareToast.show("Saved: " + path)       }
    }

    // ================================================================
    //  MANAGE NAMES DIALOG
    // ================================================================
    Dialog {
        id: manageNamesDialog
        title: "Manage Names"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Close
        width: 280

        ColumnLayout {
            width: parent.width
            spacing: 8

            Label { text: "Current names:"; font.bold: true; font.pixelSize: 11 }

            Rectangle {
                Layout.fillWidth: true
                height: 200
                border.color: "#ccc"
                clip: true

                ListView {
                    anchors.fill: parent
                    model: sessionNames
                    ScrollBar.vertical: ScrollBar {}

                    delegate: RowLayout {
                        width: ListView.view.width
                        spacing: 4
                        Label {
                            text: modelData
                            Layout.fillWidth: true
                            leftPadding: 6
                            verticalAlignment: Text.AlignVCenter
                        }
                        Button {
                            text: "✕"
                            flat: true
                            implicitWidth: 28; implicitHeight: 28
                            font.pixelSize: 10
                            onClicked: {
                                var updated = sessionNames.slice()
                                updated.splice(index, 1)
                                sessionNames = updated
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: manageNewNameField
                    placeholderText: "Add new name…"
                    Layout.fillWidth: true
                    onAccepted: addManagedNameBtn.clicked()
                }
                Button {
                    id: addManagedNameBtn
                    text: "Add"
                    onClicked: {
                        var name = manageNewNameField.text.trim()
                        if (name.length > 0 && sessionNames.indexOf(name) === -1) {
                            sessionNames = sessionNames.concat([name])
                            manageNewNameField.text = ""
                        }
                    }
                }
            }

            Button {
                text: "Reset to defaults"
                Layout.alignment: Qt.AlignRight
                flat: true
                font.pixelSize: 11
                onClicked: sessionNames = personNames.names.slice()
            }
        }
    }

    // ================================================================
    //  ADD PERSON DIALOG
    // ================================================================
    Dialog {
        id: addPersonDialog
        title: "Add Person"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 260

        ColumnLayout {
            width: parent.width
            spacing: 8

            Label { text: "Select a name:"; font.bold: true; font.pixelSize: 11 }

            Rectangle {
                Layout.fillWidth: true
                height: Math.min(personNames.names.length * 36, 180)
                border.color: "#ccc"
                clip: true

                ListView {
                    id: nameListView
                    anchors.fill: parent
                    model: sessionNames
                    currentIndex: -1
                    ScrollBar.vertical: ScrollBar {}

                    delegate: ItemDelegate {
                        width: ListView.view.width
                        text: modelData
                        highlighted: ListView.isCurrentItem
                        onClicked: {
                            nameListView.currentIndex = index
                            newPersonField.text = modelData
                        }
                    }
                }
            }

            Label { text: "Or type a custom name:"; font.pixelSize: 11 }
            TextField {
                id: newPersonField
                placeholderText: "e.g. Ahmad"
                Layout.fillWidth: true
            }
        }

        onAccepted: {
            var name = newPersonField.text.trim()
            if (name.length > 0) {
                calculator.addPerson(name)
                // Persist custom names into the session list so they appear
                // in the Pay To dropdown and future Add Person lists.
                if (sessionNames.indexOf(name) === -1)
                    sessionNames = sessionNames.concat([name])
                newPersonField.text = ""
                nameListView.currentIndex = -1
            }
        }
        onRejected: {
            newPersonField.text = ""
            nameListView.currentIndex = -1
        }
    }

} // end ApplicationWindow
