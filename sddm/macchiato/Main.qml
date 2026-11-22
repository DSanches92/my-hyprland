// Tema SDDM "macchiato": mesma identidade visual do hyprlock
// (wallpaper desfocado, relógio central, campo de senha roxo).
// Paleta Catppuccin Macchiato, mesma usada no resto dos dotfiles.

import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: root
    width: 2560
    height: 1080
    color: c.crust

    QtObject {
        id: c
        readonly property color crust:    "#181926"
        readonly property color mantle:   "#1e2030"
        readonly property color base:     "#24273a"
        readonly property color surface0: "#363a4f"
        readonly property color surface1: "#494d64"
        readonly property color overlay0: "#6e738d"
        readonly property color subtext0: "#a5adcb"
        readonly property color text:     "#cad3f5"
        readonly property color mauve:    "#c6a0f6"
        readonly property color red:      "#ed8796"
        readonly property color peach:    "#f5a97f"
    }

    readonly property string fontFamily: config.font || "GeistMono Nerd Font"
    readonly property var ptBR: Qt.locale("pt_BR")

    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property string userName: ""
    property string userRealName: ""
    property string userIcon: ""
    property string sessionName: ""
    property bool failed: false
    property string pendingAction: ""   // "poweroff" | "reboot" | "suspend"

    // userModel/sessionModel não expõem get(); um Repeater invisível lê os papéis.
    Repeater {
        model: userModel
        Item {
            required property int index
            required property string name
            required property string realName
            required property string icon
            Component.onCompleted: if (index === root.userIndex) root.pickUser(name, realName, icon)
            Connections {
                target: root
                function onUserIndexChanged() { if (index === root.userIndex) root.pickUser(name, realName, icon) }
            }
        }
    }
    Repeater {
        model: sessionModel
        Item {
            required property int index
            required property string name
            Component.onCompleted: if (index === root.sessionIndex) root.sessionName = name
            Connections {
                target: root
                function onSessionIndexChanged() { if (index === root.sessionIndex) root.sessionName = name }
            }
        }
    }

    function pickUser(name, realName, icon) {
        userName = name
        userRealName = realName
        userIcon = icon
    }

    function doLogin() {
        if (password.text.length === 0) return
        failed = false
        sddm.login(userName, password.text, sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.failed = true
            password.text = ""
            password.forceActiveFocus()
            shake.restart()
        }
    }

    Image {
        anchors.fill: parent
        source: config.background || "assets/background.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
    }

    // ---------- relógio ----------
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.17
        spacing: 4

        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            color: c.text
            font { family: root.fontFamily; pixelSize: 120; weight: Font.Light }
            text: Qt.formatTime(new Date(), "HH:mm")
        }
        Text {
            id: date
            anchors.horizontalCenter: parent.horizontalCenter
            color: c.subtext0
            font { family: root.fontFamily; pixelSize: 24 }
            text: root.ptBR.toString(new Date(), "dddd, d 'de' MMMM")
        }
        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: {
                const now = new Date()
                clock.text = Qt.formatTime(now, "HH:mm")
                date.text = root.ptBR.toString(now, "dddd, d 'de' MMMM")
            }
        }
    }

    // ---------- card de login ----------
    Rectangle {
        id: card
        width: 380
        height: cardContent.implicitHeight + 64
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.48
        radius: 24
        color: Qt.rgba(0.141, 0.153, 0.227, 0.72)   // base com transparência
        border.color: Qt.rgba(0.776, 0.627, 0.965, 0.25)
        border.width: 1

        SequentialAnimation {
            id: shake
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: -12; duration: 50 }
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: 12; duration: 70 }
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: -8; duration: 60 }
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
        }

        Column {
            id: cardContent
            anchors.centerIn: parent
            width: parent.width - 64
            spacing: 18

            // avatar circular com anel roxo
            Item {
                width: 132; height: 132
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: c.mauve
                    border.width: 3
                }
                Image {
                    id: avatar
                    anchors.centerIn: parent
                    width: 120; height: 120
                    source: root.userIcon
                    sourceSize: Qt.size(256, 256)
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                    layer.enabled: true
                }
                Rectangle {
                    id: avatarMask
                    anchors.fill: avatar
                    radius: width / 2
                    visible: false
                    layer.enabled: true
                }
                MultiEffect {
                    anchors.fill: avatar
                    source: avatar
                    maskEnabled: true
                    maskSource: avatarMask
                    visible: avatar.status === Image.Ready
                }
                // sem foto: inicial do nome
                Rectangle {
                    anchors.centerIn: parent
                    width: 120; height: 120; radius: 60
                    color: c.surface0
                    visible: avatar.status !== Image.Ready
                    Text {
                        anchors.centerIn: parent
                        color: c.mauve
                        font { family: root.fontFamily; pixelSize: 52; bold: true }
                        text: (root.userRealName || root.userName).charAt(0).toUpperCase()
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: c.text
                font { family: root.fontFamily; pixelSize: 22; weight: Font.Medium }
                text: root.userRealName || root.userName
                MouseArea {
                    anchors.fill: parent
                    enabled: userModel.count > 1
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.userIndex = (root.userIndex + 1) % userModel.count
                }
            }

            TextField {
                id: password
                width: parent.width
                height: 50
                focus: true
                echoMode: TextInput.Password
                passwordCharacter: "●"
                horizontalAlignment: TextInput.AlignHCenter
                color: c.text
                font { family: root.fontFamily; pixelSize: 16 }
                selectionColor: c.mauve
                selectedTextColor: c.base
                onAccepted: root.doLogin()
                onTextEdited: root.failed = false
                background: Rectangle {
                    radius: 25
                    color: c.base
                    border.width: 2
                    border.color: root.failed ? c.red
                                : keyboard.capsLock ? c.peach
                                : password.activeFocus ? c.mauve : c.surface1
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
                Keys.onEscapePressed: text = ""
                // cursor some com o campo vazio para não cobrir o "Senha..."; a borda roxa já indica o foco
                cursorDelegate: Rectangle {
                    width: 2
                    color: c.mauve
                    opacity: password.text.length > 0 ? 1 : 0
                }

                Text {
                    anchors.centerIn: parent
                    visible: password.text.length === 0
                    color: c.overlay0
                    font: password.font
                    text: "Senha..."
                }
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font { family: root.fontFamily; pixelSize: 14 }
                color: root.failed ? c.red : c.peach
                text: root.failed ? "Senha incorreta"
                    : keyboard.capsLock ? "  Caps Lock ligado" : " "
            }
        }
    }

    // ---------- sessão (canto inferior esquerdo) ----------
    BarButton {
        id: sessionButton
        anchors { left: parent.left; bottom: parent.bottom; margins: 32 }
        icon: ""
        label: root.sessionName
        onClicked: sessionPopup.open()
    }

    Popup {
        id: sessionPopup
        x: sessionButton.x
        y: sessionButton.y - height - 10
        width: Math.max(220, sessionButton.width)
        padding: 6
        onClosed: password.forceActiveFocus()
        background: Rectangle {
            radius: 14
            color: c.mantle
            border.color: c.surface1
        }
        contentItem: ListView {
            implicitHeight: contentHeight
            interactive: false
            model: sessionModel
            delegate: Rectangle {
                required property int index
                required property string name
                width: ListView.view.width
                height: 40
                radius: 10
                color: hover.hovered ? c.surface0 : "transparent"
                HoverHandler { id: hover }
                Text {
                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 14 }
                    color: index === root.sessionIndex ? c.mauve : c.text
                    font { family: root.fontFamily; pixelSize: 15 }
                    text: name
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.sessionIndex = index; sessionPopup.close() }
                }
            }
        }
    }

    // ---------- energia (canto inferior direito) ----------
    Row {
        anchors { right: parent.right; bottom: parent.bottom; margins: 32 }
        spacing: 12
        BarButton {
            icon: ""; label: "Suspender"
            onClicked: root.pendingAction = "suspend"
        }
        BarButton {
            icon: ""; label: "Reiniciar"
            onClicked: root.pendingAction = "reboot"
        }
        BarButton {
            icon: ""; label: "Desligar"; accent: c.red
            onClicked: root.pendingAction = "poweroff"
        }
    }

    // ---------- confirmação de energia ----------
    Rectangle {
        id: confirm
        anchors.fill: parent
        color: Qt.rgba(0.094, 0.098, 0.149, 0.6)
        visible: root.pendingAction !== ""
        onVisibleChanged: visible ? confirmBox.forceActiveFocus() : password.forceActiveFocus()

        readonly property var texts: ({
            poweroff: ["", "Desligar o computador?", "Desligar"],
            reboot:   ["", "Reiniciar o computador?", "Reiniciar"],
            suspend:  ["", "Suspender o computador?", "Suspender"]
        })
        readonly property var t: texts[root.pendingAction] || ["", "", ""]

        MouseArea { anchors.fill: parent; onClicked: root.pendingAction = "" }

        Rectangle {
            id: confirmBox
            anchors.centerIn: parent
            width: 420; height: 230
            radius: 24
            color: c.base
            border.color: c.surface1
            Keys.onEscapePressed: root.pendingAction = ""
            Keys.onReturnPressed: confirm.run()
            Keys.onEnterPressed: confirm.run()
            MouseArea { anchors.fill: parent }   // não fecha ao clicar dentro

            Column {
                anchors.centerIn: parent
                spacing: 16
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.pendingAction === "poweroff" ? c.red : c.mauve
                    font { family: root.fontFamily; pixelSize: 40 }
                    text: confirm.t[0]
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: c.text
                    font { family: root.fontFamily; pixelSize: 20 }
                    text: confirm.t[1]
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12
                    BarButton { label: "Cancelar"; onClicked: root.pendingAction = "" }
                    BarButton {
                        label: confirm.t[2]
                        accent: root.pendingAction === "poweroff" ? c.red : c.mauve
                        filled: true
                        onClicked: confirm.run()
                    }
                }
            }
        }

        function run() {
            const a = root.pendingAction
            root.pendingAction = ""
            if (a === "poweroff") sddm.powerOff()
            else if (a === "reboot") sddm.reboot()
            else if (a === "suspend") sddm.suspend()
        }
    }

    component BarButton: Rectangle {
        id: btn
        property string icon: ""
        property string label: ""
        property color accent: c.mauve
        property bool filled: false
        signal clicked()

        width: content.implicitWidth + 32
        height: 44
        radius: 22
        color: filled ? accent
             : area.containsMouse ? Qt.rgba(0.212, 0.227, 0.310, 0.95)
             : Qt.rgba(0.141, 0.153, 0.227, 0.72)
        border.width: 1
        border.color: area.containsMouse ? accent : Qt.rgba(0.286, 0.302, 0.392, 0.6)
        Behavior on color { ColorAnimation { duration: 120 } }

        Row {
            id: content
            anchors.centerIn: parent
            spacing: 10
            Text {
                visible: btn.icon !== ""
                color: btn.filled ? c.base : btn.accent
                font { family: root.fontFamily; pixelSize: 17 }
                text: btn.icon
            }
            Text {
                visible: btn.label !== ""
                color: btn.filled ? c.base : c.text
                font { family: root.fontFamily; pixelSize: 15; weight: btn.filled ? Font.Bold : Font.Normal }
                text: btn.label
            }
        }
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
