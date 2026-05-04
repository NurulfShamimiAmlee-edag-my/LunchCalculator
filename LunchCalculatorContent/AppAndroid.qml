import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore

ApplicationWindow {
    id: root
    visible: true
    width: 390
    height: 844

    // ── Colour palette ───────────────────────────────────────────────────
    readonly property color colBg:      "#121212"
    readonly property color colCard:    "#1e1e2e"
    readonly property color colHeader:  "#1a3a5c"
    readonly property color colAccent:  "#7c4dff"
    readonly property color colYellow:  "#ffff00"
    readonly property color colText:    "#ffffff"
    readonly property color colSubtext: "#888888"
    readonly property color colRed:     "#f44336"
    readonly property color colGreen:   "#4caf50"
    readonly property color colInput:   "#2a2a3e"

    readonly property var personColors: [
        "#7c4dff", "#e91e63", "#00bcd4", "#4caf50",
        "#ff9800", "#f44336", "#9c27b0", "#03a9f4"
    ]

    function personColor(idx) {
        return personColors[idx % personColors.length]
    }

    function personInitials(name) {
        var parts = name.trim().split(" ")
        return parts.length > 1
            ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
            : name.substring(0, 2).toUpperCase()
    }

    function fmt(n) { return root.currencySymbol + " " + n.toFixed(2) }

    color: colBg

    // ── Currency ───────────────────────────────────────────────────
    property var currencySymbol: "MYR"

    readonly property var allCurrencies: [
        {code:"AED",name:"UAE Dirham"},{code:"AFN",name:"Afghan Afghani"},
        {code:"ALL",name:"Albanian Lek"},{code:"AMD",name:"Armenian Dram"},
        {code:"ANG",name:"Netherlands Antillean Guilder"},{code:"AOA",name:"Angolan Kwanza"},
        {code:"ARS",name:"Argentine Peso"},{code:"AUD",name:"Australian Dollar"},
        {code:"AWG",name:"Aruban Florin"},{code:"AZN",name:"Azerbaijani Manat"},
        {code:"BAM",name:"Bosnia-Herzegovina Mark"},{code:"BBD",name:"Barbadian Dollar"},
        {code:"BDT",name:"Bangladeshi Taka"},{code:"BGN",name:"Bulgarian Lev"},
        {code:"BHD",name:"Bahraini Dinar"},{code:"BIF",name:"Burundian Franc"},
        {code:"BMD",name:"Bermudian Dollar"},{code:"BND",name:"Brunei Dollar"},
        {code:"BOB",name:"Bolivian Boliviano"},{code:"BRL",name:"Brazilian Real"},
        {code:"BSD",name:"Bahamian Dollar"},{code:"BTN",name:"Bhutanese Ngultrum"},
        {code:"BWP",name:"Botswanan Pula"},{code:"BYN",name:"Belarusian Ruble"},
        {code:"BZD",name:"Belize Dollar"},{code:"CAD",name:"Canadian Dollar"},
        {code:"CDF",name:"Congolese Franc"},{code:"CHF",name:"Swiss Franc"},
        {code:"CLP",name:"Chilean Peso"},{code:"CNY",name:"Chinese Yuan"},
        {code:"COP",name:"Colombian Peso"},{code:"CRC",name:"Costa Rican Colón"},
        {code:"CUP",name:"Cuban Peso"},{code:"CVE",name:"Cape Verdean Escudo"},
        {code:"CZK",name:"Czech Koruna"},{code:"DJF",name:"Djiboutian Franc"},
        {code:"DKK",name:"Danish Krone"},{code:"DOP",name:"Dominican Peso"},
        {code:"DZD",name:"Algerian Dinar"},{code:"EGP",name:"Egyptian Pound"},
        {code:"ERN",name:"Eritrean Nakfa"},{code:"ETB",name:"Ethiopian Birr"},
        {code:"EUR",name:"Euro"},{code:"FJD",name:"Fijian Dollar"},
        {code:"FKP",name:"Falkland Islands Pound"},{code:"GBP",name:"British Pound"},
        {code:"GEL",name:"Georgian Lari"},{code:"GHS",name:"Ghanaian Cedi"},
        {code:"GIP",name:"Gibraltar Pound"},{code:"GMD",name:"Gambian Dalasi"},
        {code:"GNF",name:"Guinean Franc"},{code:"GTQ",name:"Guatemalan Quetzal"},
        {code:"GYD",name:"Guyanese Dollar"},{code:"HKD",name:"Hong Kong Dollar"},
        {code:"HNL",name:"Honduran Lempira"},{code:"HRK",name:"Croatian Kuna"},
        {code:"HTG",name:"Haitian Gourde"},{code:"HUF",name:"Hungarian Forint"},
        {code:"IDR",name:"Indonesian Rupiah"},{code:"ILS",name:"Israeli Shekel"},
        {code:"INR",name:"Indian Rupee"},{code:"IQD",name:"Iraqi Dinar"},
        {code:"IRR",name:"Iranian Rial"},{code:"ISK",name:"Icelandic Króna"},
        {code:"JMD",name:"Jamaican Dollar"},{code:"JOD",name:"Jordanian Dinar"},
        {code:"JPY",name:"Japanese Yen"},{code:"KES",name:"Kenyan Shilling"},
        {code:"KGS",name:"Kyrgystani Som"},{code:"KHR",name:"Cambodian Riel"},
        {code:"KMF",name:"Comorian Franc"},{code:"KPW",name:"North Korean Won"},
        {code:"KRW",name:"South Korean Won"},{code:"KWD",name:"Kuwaiti Dinar"},
        {code:"KYD",name:"Cayman Islands Dollar"},{code:"KZT",name:"Kazakhstani Tenge"},
        {code:"LAK",name:"Laotian Kip"},{code:"LBP",name:"Lebanese Pound"},
        {code:"LKR",name:"Sri Lankan Rupee"},{code:"LRD",name:"Liberian Dollar"},
        {code:"LSL",name:"Lesotho Loti"},{code:"LYD",name:"Libyan Dinar"},
        {code:"MAD",name:"Moroccan Dirham"},{code:"MDL",name:"Moldovan Leu"},
        {code:"MGA",name:"Malagasy Ariary"},{code:"MKD",name:"Macedonian Denar"},
        {code:"MMK",name:"Myanmar Kyat"},{code:"MNT",name:"Mongolian Tögrög"},
        {code:"MOP",name:"Macanese Pataca"},{code:"MRU",name:"Mauritanian Ouguiya"},
        {code:"MUR",name:"Mauritian Rupee"},{code:"MVR",name:"Maldivian Rufiyaa"},
        {code:"MWK",name:"Malawian Kwacha"},{code:"MXN",name:"Mexican Peso"},
        {code:"MYR",name:"Malaysian Ringgit"},{code:"MZN",name:"Mozambican Metical"},
        {code:"NAD",name:"Namibian Dollar"},{code:"NGN",name:"Nigerian Naira"},
        {code:"NIO",name:"Nicaraguan Córdoba"},{code:"NOK",name:"Norwegian Krone"},
        {code:"NPR",name:"Nepalese Rupee"},{code:"NZD",name:"New Zealand Dollar"},
        {code:"OMR",name:"Omani Rial"},{code:"PAB",name:"Panamanian Balboa"},
        {code:"PEN",name:"Peruvian Sol"},{code:"PGK",name:"Papua New Guinean Kina"},
        {code:"PHP",name:"Philippine Peso"},{code:"PKR",name:"Pakistani Rupee"},
        {code:"PLN",name:"Polish Złoty"},{code:"PYG",name:"Paraguayan Guaraní"},
        {code:"QAR",name:"Qatari Riyal"},{code:"RON",name:"Romanian Leu"},
        {code:"RSD",name:"Serbian Dinar"},{code:"RUB",name:"Russian Ruble"},
        {code:"RWF",name:"Rwandan Franc"},{code:"SAR",name:"Saudi Riyal"},
        {code:"SBD",name:"Solomon Islands Dollar"},{code:"SCR",name:"Seychellois Rupee"},
        {code:"SDG",name:"Sudanese Pound"},{code:"SEK",name:"Swedish Krona"},
        {code:"SGD",name:"Singapore Dollar"},{code:"SHP",name:"Saint Helena Pound"},
        {code:"SLL",name:"Sierra Leonean Leone"},{code:"SOS",name:"Somali Shilling"},
        {code:"SRD",name:"Surinamese Dollar"},{code:"SSP",name:"South Sudanese Pound"},
        {code:"STN",name:"São Tomé & Príncipe Dobra"},{code:"SVC",name:"Salvadoran Colón"},
        {code:"SYP",name:"Syrian Pound"},{code:"SZL",name:"Swazi Lilangeni"},
        {code:"THB",name:"Thai Baht"},{code:"TJS",name:"Tajikistani Somoni"},
        {code:"TMT",name:"Turkmenistani Manat"},{code:"TND",name:"Tunisian Dinar"},
        {code:"TOP",name:"Tongan Paʻanga"},{code:"TRY",name:"Turkish Lira"},
        {code:"TTD",name:"Trinidad & Tobago Dollar"},{code:"TWD",name:"New Taiwan Dollar"},
        {code:"TZS",name:"Tanzanian Shilling"},{code:"UAH",name:"Ukrainian Hryvnia"},
        {code:"UGX",name:"Ugandan Shilling"},{code:"USD",name:"US Dollar"},
        {code:"UYU",name:"Uruguayan Peso"},{code:"UZS",name:"Uzbekistani Som"},
        {code:"VES",name:"Venezuelan Bolívar"},{code:"VND",name:"Vietnamese Đồng"},
        {code:"VUV",name:"Vanuatu Vatu"},{code:"WST",name:"Samoan Tālā"},
        {code:"XAF",name:"Central African CFA Franc"},{code:"XCD",name:"East Caribbean Dollar"},
        {code:"XOF",name:"West African CFA Franc"},{code:"XPF",name:"CFP Franc"},
        {code:"YER",name:"Yemeni Rial"},{code:"ZAR",name:"South African Rand"},
        {code:"ZMW",name:"Zambian Kwacha"},{code:"ZWL",name:"Zimbabwean Dollar"}
    ]

    // ── Session names (same settings key as desktop) ─────────────────────
    PersonNames { id: personNames }

    Settings {
        id: appSettings
        category: "NamesManager"
        property string namesJson: ""
    }

    property var sessionNames: []

    Component.onCompleted: {
        sessionNames = appSettings.namesJson !== ""
            ? JSON.parse(appSettings.namesJson)
            : personNames.names.slice()
    }

    // ── Navigation ───────────────────────────────────────────────────────
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainPage
    }

    // ── Toast notification ───────────────────────────────────────────────
    Rectangle {
        id: toastBar
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 90 }
        width: toastLabel.implicitWidth + 32
        height: 40; radius: 20
        color: "#333"
        opacity: 0
        z: 100

        Label {
            id: toastLabel
            anchors.centerIn: parent
            color: "white"; font.pixelSize: 13
        }

        SequentialAnimation {
            id: toastAnim
            NumberAnimation { target: toastBar; property: "opacity"; to: 1; duration: 200 }
            PauseAnimation  { duration: 2500 }
            NumberAnimation { target: toastBar; property: "opacity"; to: 0; duration: 300 }
        }
    }

    function showToast(msg) {
        toastLabel.text = msg
        toastAnim.restart()
    }

    Connections {
        target: imageExporter
        function onCopyDone() { root.showToast("Copied to clipboard!") }
        function onSaveDone(path) { root.showToast("Saved: " + path) }
    }

    // ====================================================================
    //  MAIN PAGE
    // ====================================================================
    Component {
        id: mainPage

        Page {
            id: mainRoot
            background: Rectangle { color: root.colBg }

            ScrollView {
                id: mainScroll
                anchors { top: parent.top; left: parent.left; right: parent.right; bottom: bottomBar.top }
                contentWidth: width
                clip: true

                Column {
                    id: mainColumn
                    width: mainScroll.width
                    padding: 12
                    spacing: 12

                    // ── Session card ─────────────────────────────────────
                    Rectangle {
                        width: parent.width - 24
                        color: root.colCard
                        radius: 12
                        height: sessionGrid.implicitHeight + 24

                        GridLayout {
                            id: sessionGrid
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            columns: 2
                            rowSpacing: 6
                            columnSpacing: 8

                            Label { text: "PLACE";   color: root.colSubtext; font.pixelSize: 10 }
                            Label { text: "DATE";    color: root.colSubtext; font.pixelSize: 10 }

                            TextField {
                                Layout.fillWidth: true
                                text: calculator.place
                                onTextChanged: calculator.place = text
                                color: root.colText
                                background: Rectangle { color: root.colInput; radius: 6 }
                            }
                            TextField {
                                Layout.fillWidth: true
                                text: calculator.date
                                onTextChanged: calculator.date = text
                                color: root.colText
                                background: Rectangle { color: root.colInput; radius: 6 }
                            }

                            Label { text: "PAY TO"; color: root.colSubtext; font.pixelSize: 10; Layout.columnSpan: 2 }
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.columnSpan: 2
                                spacing: 4

                                TextField {
                                    id: payToField
                                    Layout.fillWidth: true
                                    text: calculator.payTo
                                    onTextChanged: calculator.payTo = text
                                    color: root.colText
                                    background: Rectangle { color: root.colInput; radius: 6 }
                                }

                                Button {
                                    id: payToDropBtn
                                    implicitWidth: 36
                                    implicitHeight: payToField.implicitHeight
                                    visible: calculator.persons.length > 0
                                    background: Rectangle { color: root.colAccent; radius: 6 }
                                    contentItem: Label {
                                        text: "▼"; color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: payToPopup.open()
                                }
                            }

                            // Pay To person picker — plain Popup avoids Repeater-in-Menu issues
                            Popup {
                                id: payToPopup
                                x: parent.width - width
                                y: payToDropBtn.y + payToDropBtn.height + 2
                                width: Math.min(parent.width * 0.6, 220)
                                height: Math.min(calculator.persons.length * 44 + 16, 260)
                                modal: false
                                background: Rectangle { color: root.colCard; radius: 8; border.color: "#444"; border.width: 1 }

                                Column {
                                    anchors { fill: parent; margins: 8 }
                                    spacing: 2
                                    Repeater {
                                        model: calculator.persons
                                        ItemDelegate {
                                            width: parent.width
                                            height: 40
                                            contentItem: Label {
                                                text: modelData
                                                color: root.colText
                                                font.pixelSize: 14
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            background: Rectangle {
                                                color: "transparent"
                                                Rectangle {
                                                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                                                    height: 1; color: "#333"
                                                }
                                            }
                                            onClicked: {
                                                calculator.payTo = modelData
                                                payToPopup.close()
                                            }
                                        }
                                    }
                                }
                            }

                            Label { text: "SERV. CHARGE (%)"; color: root.colSubtext; font.pixelSize: 10 }
                            Label { text: "SST (%)";          color: root.colSubtext; font.pixelSize: 10 }

                            TextField {
                                Layout.fillWidth: true
                                text: calculator.serviceChargePct
                                onEditingFinished: calculator.serviceChargePct = parseFloat(text) || 0
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                color: root.colText
                                background: Rectangle { color: root.colInput; radius: 6 }
                            }
                            TextField {
                                Layout.fillWidth: true
                                text: calculator.sstPct
                                onEditingFinished: calculator.sstPct = parseFloat(text) || 0
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                color: root.colText
                                background: Rectangle { color: root.colInput; radius: 6 }
                            }

                            Label { text: "APPLY TO ALL"; color: root.colSubtext; font.pixelSize: 10; Layout.columnSpan: 2 }
                            RowLayout {
                                Layout.columnSpan: 2
                                Layout.fillWidth: true
                                spacing: 16
                                Row {
                                    spacing: 6
                                    Label { text: "SC"; color: root.colText; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                                    Switch {
                                        checked: calculator.allSC
                                        onToggled: calculator.model.setAllSC(checked)
                                    }
                                }
                                Row {
                                    spacing: 6
                                    Label { text: "SST"; color: root.colText; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                                    Switch {
                                        checked: calculator.allSST
                                        onToggled: calculator.model.setAllSST(checked)
                                    }
                                }
                                Item { Layout.fillWidth: true }
                                Button {
                                    implicitWidth: 64
                                    implicitHeight: 32
                                    background: Rectangle {
                                        color: root.colInput; radius: 6
                                        border.color: root.colAccent; border.width: 1
                                    }
                                    contentItem: Label {
                                        text: root.currencySymbol
                                        color: root.colAccent; font.bold: true; font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: currencySheet.open()
                                }
                            }
                        }
                    }

                    // ── Persons card ─────────────────────────────────────
                    Rectangle {
                        width: parent.width - 24
                        color: root.colCard
                        radius: 12
                        height: personsCol.implicitHeight + 24

                        Column {
                            id: personsCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            spacing: 12

                            RowLayout {
                                width: parent.width
                                Label {
                                    text: "SPLITTING BETWEEN"
                                    color: root.colSubtext
                                    font.pixelSize: 10
                                    Layout.fillWidth: true
                                }
                                Button {
                                    text: "Manage"
                                    padding: 6
                                    background: Rectangle { color: root.colAccent; radius: 10 }
                                    contentItem: Label {
                                        text: parent.text; color: "white"
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: stackView.push(peoplePage)
                                }
                            }

                            Label {
                                text: "Tap a person to assign their orders"
                                color: root.colSubtext
                                font.pixelSize: 10
                                font.italic: true
                                visible: calculator.persons.length > 0
                            }

                            Flow {
                                width: parent.width
                                spacing: 16

                                Repeater {
                                    model: calculator.personTotals
                                    delegate: Column {
                                        spacing: 4
                                        width: 70

                                        Rectangle {
                                            width: 36; height: 36; radius: 18
                                            color: root.personColor(index)
                                            anchors.horizontalCenter: parent.horizontalCenter

                                            Label {
                                                anchors.centerIn: parent
                                                text: root.personInitials(modelData.name)
                                                color: "white"
                                                font.bold: true
                                                font.pixelSize: 11
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: stackView.push(personOrdersPage, {
                                                    personIndex: index,
                                                    personName: modelData.name
                                                })
                                            }
                                        }

                                        Label {
                                            text: modelData.name
                                            color: root.colText
                                            font.pixelSize: 11
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            elide: Text.ElideRight
                                            width: parent.width
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        Label {
                                            text: "Food " + root.fmt(modelData.food)
                                            color: root.colSubtext
                                            font.pixelSize: 9
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            elide: Text.ElideRight
                                            width: parent.width
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        Label {
                                            text: "SC+SST " + root.fmt(modelData.serviceCharge + modelData.tax)
                                            color: root.colSubtext; font.pixelSize: 9
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Label {
                                            text: root.currencySymbol + " " + modelData.total.toFixed(2)
                                            color: root.colYellow; font.bold: true; font.pixelSize: 16
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }                                        
                                    }
                                }
                            }
                        }
                    }

                    // ── Items card ───────────────────────────────────────
                    Rectangle {
                        width: parent.width - 24
                        color: root.colCard
                        radius: 12
                        height: itemsCol.implicitHeight + 24

                        Column {
                            id: itemsCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            spacing: 0

                            RowLayout {
                                width: parent.width

                                Label { text: "Items"; color: root.colText; font.pixelSize: 15; Layout.fillWidth: true }

                                Rectangle {
                                    color: root.colAccent; radius: 10
                                    width: itemBadge.implicitWidth + 16; height: 20
                                    Label {
                                        id: itemBadge
                                        anchors.centerIn: parent
                                        text: calculator.itemCount + " items"
                                        color: "white"; font.pixelSize: 11
                                    }
                                }
                            }

                            Label {
                                text: "Tap an item to edit it"
                                color: root.colSubtext
                                font.pixelSize: 10
                                font.italic: true
                                bottomPadding: 8
                                visible: calculator.itemCount > 0
                            }

                            Repeater {
                                model: calculator.itemsData

                                delegate: ItemDelegate {
                                    width: parent.width
                                    background: Rectangle {
                                        color: "transparent"
                                        Rectangle {
                                            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                            height: 1
                                            color: "#2a2a3e"
                                        }
                                    }
                                    contentItem: RowLayout {
                                        spacing: 8
                                        Column {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            Label {
                                                text: modelData.name || "(unnamed)"
                                                color: root.colText
                                                font.pixelSize: 14
                                                width: parent.width
                                                elide: Text.ElideRight
                                            }
                                            Label {
                                                text: (modelData.qty > 1 ? modelData.qty + "×" + modelData.price.toFixed(2) + "  " : "")
                                                      + (modelData.sc ? "SC" : "") + (modelData.sc && modelData.taxable ? " · " : "") + (modelData.taxable ? "SST" : "")
                                                color: root.colSubtext
                                                font.pixelSize: 10
                                            }
                                        }
                                        Label {
                                            text: root.currencySymbol + " " +(modelData.qty * modelData.price).toFixed(2)
                                            color: modelData.price < 0 ? root.colGreen : root.colText
                                            font.pixelSize: 14
                                            font.bold: modelData.price < 0
                                        }
                                    }
                                    onClicked: {
                                        editSheet.editRow = index
                                        editSheet.initialName = modelData.name || ""
                                        editSheet.initialQty = modelData.qty || 1
                                        editSheet.initialPrice = modelData.price || 0
                                        editSheet.initialSc = modelData.sc !== undefined ? modelData.sc : true
                                        editSheet.initialTaxable = modelData.taxable !== undefined ? modelData.taxable : false
                                        editSheet.isNew = false
                                        editSheet.open()
                                    }
                                }
                            }
                        }
                    }

                    // ── Summary card ─────────────────────────────────────
                    Rectangle {
                        width: parent.width - 24
                        color: root.colCard
                        radius: 12
                        height: summaryCol.implicitHeight + 24

                        Column {
                            id: summaryCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            spacing: 6

                            component SummaryRow: RowLayout {
                                property string label: ""
                                property string value: ""
                                property color  valueColor: root.colText
                                property bool   bold: false
                                width: parent.width

                                Label {
                                    text: parent.label
                                    color: root.colText
                                    font.bold: parent.bold
                                    font.pixelSize: parent.bold ? 15 : 13
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: parent.value
                                    color: parent.valueColor
                                    font.bold: parent.bold
                                    font.pixelSize: parent.bold ? 15 : 13
                                }
                            }

                            SummaryRow { label: "Subtotal";  value: root.fmt(calculator.subtotal) }
                            Rectangle  { width: parent.width; height: 1; color: "#333" }
                            SummaryRow {
                                label: "Service Charge (" + calculator.serviceChargePct + "%)"
                                value: root.fmt(calculator.serviceCharge)
                            }
                            SummaryRow { label: "SST"; value: root.fmt(calculator.sst) }
                            Rectangle  { width: parent.width; height: 1; color: "#333" }
                            SummaryRow {
                                label: "Grand Total"; value: root.fmt(calculator.grandTotal)
                                bold: true
                            }
                            Rectangle  { width: parent.width; height: 1; color: "#333" }

                            RowLayout {
                                width: parent.width
                                Label { text: "Receipt amount"; color: root.colText; font.pixelSize: 13; Layout.fillWidth: true }
                                TextField {
                                    width: 110
                                    text: calculator.receiptAmt > 0 ? calculator.receiptAmt.toFixed(2) : ""
                                    placeholderText: "0.00"
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    color: "#000"
                                    background: Rectangle { color: root.colYellow; radius: 4 }
                                    onEditingFinished: calculator.receiptAmt = parseFloat(text) || 0
                                }
                            }

                            SummaryRow {
                                label: "Difference"
                                value: root.fmt(calculator.difference)
                                valueColor: calculator.difference < -0.005 ? root.colRed
                                          : calculator.difference >  0.005 ? root.colGreen
                                          : root.colText
                            }
                        }
                    }

                    // // ── Per-person section ───────────────────────────────
                    // Column {
                    //     width: parent.width - 24
                    //     spacing: 8

                    //     Label { text: "PER PERSON"; color: root.colSubtext; font.pixelSize: 10 }

                    //     ScrollView {
                    //         width: parent.width
                    //         height: 140
                    //         ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                    //         Row {
                    //             spacing: 10
                    //             Repeater {
                    //                 model: calculator.personTotals
                    //                 delegate: Rectangle {
                    //                     color: root.colCard; radius: 12
                    //                     width: 110; height: 130

                    //                     Column {
                    //                         anchors.centerIn: parent
                    //                         spacing: 4

                    //                         Rectangle {
                    //                             width: 36; height: 36; radius: 18
                    //                             color: root.personColor(index)
                    //                             anchors.horizontalCenter: parent.horizontalCenter
                    //                             Label {
                    //                                 anchors.centerIn: parent
                    //                                 text: root.personInitials(modelData.name)
                    //                                 color: "white"; font.bold: true; font.pixelSize: 11
                    //                             }
                    //                         }
                    //                         Label {
                    //                             text: modelData.name
                    //                             color: root.colText; font.pixelSize: 11
                    //                             anchors.horizontalCenter: parent.horizontalCenter
                    //                             elide: Text.ElideRight; width: 100
                    //                             horizontalAlignment: Text.AlignHCenter
                    //                         }
                    //                         Label {
                    //                             text: "Food " + root.fmt(modelData.food)
                    //                             color: root.colSubtext; font.pixelSize: 9
                    //                             anchors.horizontalCenter: parent.horizontalCenter
                    //                         }
                    //                         Label {
                    //                             text: "SC+SST " + root.fmt(modelData.serviceCharge + modelData.tax)
                    //                             color: root.colSubtext; font.pixelSize: 9
                    //                             anchors.horizontalCenter: parent.horizontalCenter
                    //                         }
                    //                         Label {
                    //                             text: modelData.total.toFixed(2)
                    //                             color: root.colYellow; font.bold: true; font.pixelSize: 16
                    //                             anchors.horizontalCenter: parent.horizontalCenter
                    //                         }
                    //                     }
                    //                 }
                    //             }
                    //         }
                    //     }
                    // }

                    Item { width: 1; height: 60 }  // bottom breathing room
                }
            }

            // ── Bottom bar ───────────────────────────────────────────────
            Rectangle {
                id: bottomBar
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 64
                color: root.colCard

                RowLayout {
                    anchors { fill: parent; margins: 10 }
                    spacing: 8

                    Button {
                        text: "Copy"
                        Layout.fillWidth: true
                        onClicked: imageExporter.grabAndCopy(mainRoot)
                        background: Rectangle { color: "#333"; radius: 8 }
                        contentItem: Label {
                            text: parent.text; color: root.colText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    Button {
                        text: "Save"
                        Layout.fillWidth: true
                        onClicked: imageExporter.grabAndSave(mainRoot,
                            imageExporter.defaultSavePath(calculator.place, calculator.date))
                        background: Rectangle { color: "#333"; radius: 8 }
                        contentItem: Label {
                            text: parent.text; color: root.colText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    Button {
                        text: "New"
                        Layout.fillWidth: true
                        onClicked: newBillDialog.open()
                        background: Rectangle { color: "#333"; radius: 8 }
                        contentItem: Label {
                            text: parent.text; color: root.colText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // ── FAB ──────────────────────────────────────────────────────
            RoundButton {
                anchors { bottom: bottomBar.top; right: parent.right; margins: 16 }
                width: 56; height: 56
                background: Rectangle { color: root.colAccent; radius: 28 }
                contentItem: Label {
                    text: "+"
                    color: "white"; font.pixelSize: 28; font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    editSheet.editRow = calculator.itemCount
                    editSheet.initialName = ""
                    editSheet.initialQty = 1
                    editSheet.initialPrice = 0
                    editSheet.initialSc = true
                    editSheet.initialTaxable = false
                    editSheet.isNew = true
                    editSheet.open()
                }
            }

            // ── New Bill dialog ──────────────────────────────────────────
            Dialog {
                id: newBillDialog
                title: "New Bill?"
                modal: true
                anchors.centerIn: parent
                background: Rectangle { color: root.colCard; radius: 12 }

                Label { text: "Clear all items and persons?"; color: root.colText }

                standardButtons: Dialog.Ok | Dialog.Cancel
                onAccepted: calculator.reset()
            }

            // ── Currency picker ──────────────────────────────────────────
            Popup {
                id: currencySheet
                property string searchText: ""

                width: parent.width
                height: parent.height * 0.75
                x: 0; y: parent.height - height
                modal: true
                background: Rectangle { color: root.colCard; radius: 16 }

                onOpened: searchText = ""

                Column {
                    anchors { fill: parent; margins: 16 }
                    spacing: 10

                    Label {
                        text: "Select Currency"
                        color: root.colText; font.pixelSize: 16; font.bold: true
                    }

                    TextField {
                        width: parent.width
                        placeholderText: "Search code or name…"
                        color: root.colText
                        background: Rectangle { color: root.colInput; radius: 8 }
                        onTextChanged: currencySheet.searchText = text
                    }

                    ListView {
                        width: parent.width
                        height: currencySheet.height - 130
                        clip: true
                        model: {
                            var q = currencySheet.searchText.toLowerCase()
                            return q === "" ? root.allCurrencies
                                : root.allCurrencies.filter(function(c) {
                                    return c.code.toLowerCase().indexOf(q) !== -1
                                        || c.name.toLowerCase().indexOf(q) !== -1
                                })
                        }

                        delegate: ItemDelegate {
                            width: ListView.view.width
                            implicitHeight: 44
                            contentItem: RowLayout {
                                spacing: 12
                                Label {
                                    text: modelData.code
                                    color: root.colAccent; font.bold: true; font.pixelSize: 13
                                    Layout.preferredWidth: 48
                                }
                                Label {
                                    text: modelData.name
                                    color: root.colText; font.pixelSize: 13
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Label {
                                    text: "✓"
                                    color: root.colAccent; font.pixelSize: 14
                                    visible: modelData.code === root.currencySymbol
                                }
                            }
                            background: Rectangle {
                                color: modelData.code === root.currencySymbol
                                       ? Qt.rgba(root.colAccent.r, root.colAccent.g, root.colAccent.b, 0.15)
                                       : "transparent"
                                Rectangle {
                                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                                    height: 1; color: "#2a2a3e"
                                }
                            }
                            onClicked: {
                                root.currencySymbol = modelData.code
                                currencySheet.close()
                            }
                        }
                    }
                }
            }
        }
    }

    // ====================================================================
    //  PEOPLE PAGE  —  add / remove persons
    // ====================================================================
    Component {
        id: peoplePage

        Page {
            background: Rectangle { color: root.colBg }

            header: ToolBar {
                background: Rectangle { color: root.colHeader }
                RowLayout {
                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                    ToolButton {
                        contentItem: Label { text: "←"; color: "white"; font.pixelSize: 22 }
                        onClicked: stackView.pop()
                    }
                    Label {
                        text: "People"
                        color: "white"; font.pixelSize: 18; font.bold: true
                        Layout.fillWidth: true
                    }
                }
            }

            ScrollView {
                anchors.fill: parent
                contentWidth: width

                Column {
                    width: parent.width
                    padding: 16
                    spacing: 10

                    // Existing persons
                    Repeater {
                        model: calculator.persons
                        delegate: Rectangle {
                            width: parent.width - 32
                            height: 56
                            color: root.colCard; radius: 10

                            RowLayout {
                                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }

                                Rectangle {
                                    width: 36; height: 36; radius: 18
                                    color: root.personColor(index)
                                    Label {
                                        anchors.centerIn: parent
                                        text: root.personInitials(modelData)
                                        color: "white"; font.bold: true; font.pixelSize: 12
                                    }
                                }

                                Label {
                                    text: modelData
                                    color: root.colText; font.pixelSize: 14
                                    Layout.fillWidth: true
                                }

                                RoundButton {
                                    width: 32; height: 32
                                    background: Rectangle { color: "#c0392b"; radius: 16 }
                                    contentItem: Label {
                                        text: "X"/*"✕"*/; color: "white"; font.pixelSize: 13
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: calculator.removePerson(index)
                                }
                            }
                        }
                    }

                    Rectangle { width: parent.width - 32; height: 1; color: "#333" }

                    // Custom name entry
                    Rectangle {
                        width: parent.width - 32
                        height: 48
                        color: root.colCard; radius: 10

                        TextField {
                            id: customNameField
                            anchors { fill: parent; margins: 8 }
                            placeholderText: "Enter a name…"
                            color: root.colText
                            background: null
                        }
                    }

                    RowLayout {
                        width: parent.width - 32
                        spacing: 8

                        Button {
                            text: "+ Add"
                            Layout.fillWidth: true
                            enabled: customNameField.text.trim().length > 0
                            onClicked: {
                                calculator.addPerson(customNameField.text.trim())
                                customNameField.text = ""
                            }
                            background: Rectangle { color: root.colAccent; radius: 8 }
                            contentItem: Label {
                                text: parent.text; color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "Pick from list"
                            Layout.fillWidth: true
                            onClicked: pickNameSheet.open()
                            background: Rectangle { color: "#333"; radius: 8 }
                            contentItem: Label {
                                text: parent.text; color: root.colText
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            // Pick from list bottom sheet
            Popup {
                id: pickNameSheet
                width: parent.width
                height: Math.min(parent.height * 0.6, 420)
                x: 0; y: parent.height - height
                modal: true
                background: Rectangle { color: root.colCard; radius: 16 }

                Column {
                    anchors { fill: parent; margins: 16 }
                    spacing: 8

                    Label { text: "Pick a name"; color: root.colText; font.pixelSize: 16; font.bold: true }

                    ListView {
                        width: parent.width
                        height: pickNameSheet.height - 80
                        model: root.sessionNames
                        clip: true

                        delegate: ItemDelegate {
                            width: parent.width
                            background: Rectangle { color: "transparent" }
                            contentItem: Label { text: modelData; color: root.colText; font.pixelSize: 14 }
                            onClicked: {
                                calculator.addPerson(modelData)
                                pickNameSheet.close()
                            }
                        }
                    }
                }
            }
        }
    }

    // ====================================================================
    //  PERSON ORDERS PAGE  —  checklist of items for one person
    // ====================================================================
    Component {
        id: personOrdersPage

        Page {
            id: personOrdersRoot

            property int    personIndex: 0
            property string personName:  ""

            background: Rectangle { color: root.colBg }

            header: ToolBar {
                background: Rectangle { color: root.colHeader }
                RowLayout {
                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                    ToolButton {
                        contentItem: Label { text: "←"; color: "white"; font.pixelSize: 22 }
                        onClicked: stackView.pop()
                    }
                    Label {
                        text: personOrdersRoot.personName + "'s Orders"
                        color: "white"; font.pixelSize: 18; font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }

            ScrollView {
                anchors.fill: parent
                contentWidth: width

                Column {
                    width: parent.width
                    padding: 12
                    spacing: 0

                    Label {
                        leftPadding: 4; bottomPadding: 8
                        text: "Select the items " + personOrdersRoot.personName + " ordered:"
                        color: root.colSubtext; font.pixelSize: 12; font.italic: true
                    }

                    Repeater {
                        model: calculator.itemsData

                        delegate: Rectangle {
                            width: parent.width - 24
                            height: 60
                            color: root.colCard; radius: 10
                            // small gap between rows
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                                height: 4; color: root.colBg
                            }

                            property bool isOrdered: {
                                var orders = modelData.personOrders
                                var pi = personOrdersRoot.personIndex
                                return orders && pi < orders.length ? orders[pi] : false
                            }

                            RowLayout {
                                anchors { fill: parent; leftMargin: 14; rightMargin: 14 }

                                // Checkbox circle
                                Rectangle {
                                    width: 24; height: 24; radius: 12
                                    color: parent.parent.isOrdered
                                           ? root.personColor(personOrdersRoot.personIndex)
                                           : "transparent"
                                    border.color: root.personColor(personOrdersRoot.personIndex)
                                    border.width: 2

                                    Label {
                                        anchors.centerIn: parent
                                        text: "✓"; color: "white"
                                        font.pixelSize: 14; font.bold: true
                                        visible: parent.parent.parent.isOrdered
                                    }
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Label {
                                        text: modelData.name || "(unnamed)"
                                        color: root.colText; font.pixelSize: 14
                                        elide: Text.ElideRight; width: parent.width
                                    }
                                    Label {
                                        text: modelData.taxable ? "Taxable" : "Not taxable"
                                        color: root.colSubtext; font.pixelSize: 10
                                    }
                                }

                                Label {
                                    text: (modelData.qty * modelData.price).toFixed(2)
                                    color: modelData.price < 0 ? root.colGreen : root.colText
                                    font.pixelSize: 14
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var pi     = personOrdersRoot.personIndex
                                    var orders = modelData.personOrders.slice()
                                    while (orders.length <= pi) orders.push(false)
                                    orders[pi] = !orders[pi]
                                    calculator.updateItem(index,
                                        modelData.name,
                                        modelData.qty,
                                        modelData.price,
                                        modelData.sc,
                                        modelData.taxable,
                                        orders)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ====================================================================
    //  EDIT / ADD ITEM SHEET  —  bottom popup
    // ====================================================================
    Popup {
        id: editSheet

        property int    editRow:       0
        property bool   isNew:         false
        property string initialName:   ""
        property int    initialQty:    1
        property real   initialPrice:  0
        property bool   initialSc:     true
        property bool   initialTaxable: false

        // Working copies
        property string workName:    ""
        property string workQty:     "1"
        property string workPrice:   ""
        property bool   workSc:      true
        property bool   workTaxable: false

        width: root.width
        height: Math.min(root.height * 0.7, 480)
        x: 0; y: root.height - height
        modal: true
        background: Rectangle { color: root.colCard; radius: 16 }

        onOpened: {
            workName    = initialName
            workQty     = initialQty > 0 ? initialQty.toString() : "1"
            workPrice   = initialPrice !== 0 ? initialPrice.toFixed(2) : ""
            workSc      = initialSc
            workTaxable = initialTaxable
        }

        Column {
            anchors { fill: parent; margins: 16 }
            spacing: 14

            RowLayout {
                width: parent.width
                Label {
                    text: editSheet.isNew ? "Add Item" : "Edit Item"
                    color: root.colText; font.pixelSize: 18; font.bold: true
                    Layout.fillWidth: true
                }
                Button {
                    visible: !editSheet.isNew
                    text: "Delete"
                    background: Rectangle { color: "#c0392b"; radius: 8 }
                    contentItem: Label {
                        text: parent.text; color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        calculator.removeItem(editSheet.editRow)
                        editSheet.close()
                    }
                }
            }

            Label { text: "Item name"; color: root.colSubtext; font.pixelSize: 12 }
            TextField {
                width: parent.width
                text: editSheet.workName
                onTextChanged: editSheet.workName = text
                color: root.colText
                background: Rectangle { color: root.colInput; radius: 8 }
            }

            RowLayout {
                width: parent.width
                spacing: 10
                Column {
                    Layout.fillWidth: true
                    spacing: 4
                    Label { text: "Qty"; color: root.colSubtext; font.pixelSize: 12 }
                    TextField {
                        width: parent.width + 5
                        text: editSheet.workQty
                        onTextChanged: editSheet.workQty = text
                        inputMethodHints: Qt.ImhDigitsOnly
                        color: root.colText
                        background: Rectangle { color: root.colInput; radius: 8 }
                    }
                }
                Column {
                    Layout.fillWidth: true
                    spacing: 4
                    Label { text: "Price "+ "(" + root.currencySymbol + " negative for discounts)"; color: root.colSubtext; font.pixelSize: 12 }
                    TextField {
                        width: parent.width
                        text: editSheet.workPrice
                        onTextChanged: editSheet.workPrice = text
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        color: root.colText
                        background: Rectangle { color: root.colInput; radius: 8 }
                    }
                }
            }

            RowLayout {
                width: parent.width
                Label { text: "SC"; color: root.colText; font.pixelSize: 14; Layout.fillWidth: true }
                Switch {
                    checked: editSheet.workSc
                    onCheckedChanged: editSheet.workSc = checked
                }
            }

            RowLayout {
                width: parent.width
                Label { text: "SST"; color: root.colText; font.pixelSize: 14; Layout.fillWidth: true }
                Switch {
                    checked: editSheet.workTaxable
                    onCheckedChanged: editSheet.workTaxable = checked
                }
            }

            RowLayout {
                width: parent.width
                spacing: 10

                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
                    onClicked: editSheet.close()
                    background: Rectangle { color: "#333"; radius: 8 }
                    contentItem: Label {
                        text: parent.text; color: root.colText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: "Save"
                    Layout.fillWidth: true
                    background: Rectangle { color: root.colAccent; radius: 8 }
                    contentItem: Label {
                        text: parent.text; color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        var row = editSheet.editRow
                        if (editSheet.isNew) {
                            row = calculator.itemCount
                            calculator.addItem()
                        }
                        var orders = []
                        for (var i = 0; i < calculator.persons.length; i++)
                            orders.push(false)

                        if (!editSheet.isNew) {
                            var existing = calculator.itemsData[editSheet.editRow]
                            if (existing) orders = existing.personOrders.slice()
                        }

                        calculator.updateItem(row,
                            editSheet.workName,
                            parseInt(editSheet.workQty) || 1,
                            parseFloat(editSheet.workPrice) || 0,
                            editSheet.workSc,
                            editSheet.workTaxable,
                            orders)
                        editSheet.close()
                    }
                }
            }
        }
    }
}
