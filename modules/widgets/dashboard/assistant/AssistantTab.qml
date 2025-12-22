import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.theme
import qs.config
import qs.modules.components
import qs.modules.services

Item {
    id: root
    implicitWidth: 800
    implicitHeight: 600
    
    // State
    property bool sidebarExpanded: false
    property real sidebarWidth: 250
    
    // Sidebar Animation
    Behavior on sidebarExpanded {
        NumberAnimation { duration: Config.animDuration; easing.type: Easing.OutCubic }
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // ============================================
        // SIDEBAR
        // ============================================
        Item {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: root.sidebarExpanded ? root.sidebarWidth : 0
            Layout.maximumWidth: root.sidebarWidth
            Layout.minimumWidth: 0
            clip: true
            
            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: Config.animDuration; easing.type: Easing.OutCubic }
            }
            
            StyledRect {
                anchors.fill: parent
                anchors.margins: 4
                variant: "surface"
                radius: Styling.radius(4)
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    
                    // Model Selector
                    Button {
                        Layout.fillWidth: true
                        flat: true
                        
                        contentItem: RowLayout {
                            spacing: 8
                            Text {
                                text: Icons.cpu
                                font.family: Icons.font
                                color: Colors.secondary
                                font.pixelSize: 16
                            }
                            Text {
                                text: Ai.currentModel.name
                                color: Colors.overSurface
                                font.family: Config.theme.font
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }
                            Text {
                                text: modelList.visible ? Icons.caretUp : Icons.caretDown
                                font.family: Icons.font
                                color: Colors.surfaceDim
                                font.pixelSize: 14
                            }
                        }
                        
                        background: Rectangle {
                            color: parent.hovered ? Colors.surfaceBright : "transparent"
                            radius: Styling.radius(4)
                        }
                        
                        onClicked: modelList.visible = !modelList.visible
                    }
                    
                    // Model List (Collapsible)
                    Column {
                        id: modelList
                        Layout.fillWidth: true
                        visible: false
                        
                        Repeater {
                            model: Ai.models
                            
                            Button {
                                width: modelList.width
                                height: 32
                                flat: true
                                
                                contentItem: RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 24 // Indent
                                    spacing: 8
                                    
                                    Text {
                                        text: modelData.name
                                        color: Ai.currentModel.name === modelData.name ? Colors.primary : Colors.overSurface
                                        font.family: Config.theme.font
                                        font.pixelSize: 13
                                        Layout.fillWidth: true
                                    }
                                    
                                    Text {
                                        text: Icons.accept
                                        font.family: Icons.font
                                        color: Colors.primary
                                        font.pixelSize: 12
                                        visible: Ai.currentModel.name === modelData.name
                                    }
                                }
                                
                                background: Rectangle {
                                    color: parent.hovered ? Colors.surfaceBright : "transparent"
                                    radius: Styling.radius(4)
                                }
                                
                                onClicked: {
                                    Ai.setModel(modelData.name);
                                    modelList.visible = false;
                                }
                            }
                        }
                    }
                    
                    Separator {
                        Layout.fillWidth: true
                        vert: false
                    }

                    // Header / New Chat
                    Button {
                        Layout.fillWidth: true
                        flat: true
                        
                        contentItem: RowLayout {
                            spacing: 8
                            Text {
                                text: Icons.plus
                                font.family: Icons.font
                                color: Colors.primary
                                font.pixelSize: 16
                            }
                            Text {
                                text: "New Chat"
                                color: Colors.overSurface
                                font.family: Config.theme.font
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }
                        }
                        
                        background: Rectangle {
                            color: parent.hovered ? Colors.surfaceBright : "transparent"
                            radius: Styling.radius(4)
                        }
                        
                        onClicked: {
                            Ai.createNewChat();
                            if (root.implicitWidth < 600) root.sidebarExpanded = false; // Auto close on small screens
                        }
                    }
                    
                    Separator {
                        Layout.fillWidth: true
                        vert: false
                    }
                    
                    // History List
                    ListView {
                        id: historyList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: Ai.chatHistory
                        spacing: 4
                        
                        delegate: Button {
                            width: historyList.width
                            height: 36
                            flat: true
                            
                            contentItem: Text {
                                text: {
                                    // Format timestamp to readable date/time
                                    let date = new Date(parseInt(modelData.id));
                                    return date.toLocaleString(Qt.locale(), "MM-dd hh:mm");
                                }
                                color: Ai.currentChatId === modelData.id ? Colors.primary : Colors.overSurface
                                font.family: Config.theme.font
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 8
                            }
                            
                            background: Rectangle {
                                color: parent.hovered ? Colors.surfaceBright : (Ai.currentChatId === modelData.id ? Colors.surfaceVariant : "transparent")
                                radius: Styling.radius(4)
                                border.width: Ai.currentChatId === modelData.id ? 1 : 0
                                border.color: Colors.primary
                            }
                            
                            onClicked: {
                                Ai.loadChat(modelData.id);
                            }
                        }
                    }
                }
            }
        }
        
        // ============================================
        // MAIN CHAT AREA
        // ============================================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 8
                
                // Header
                RowLayout {
                    Layout.fillWidth: true
                    height: 40
                    
                    Button {
                        flat: true
                        width: 40
                        height: 40
                        
                        contentItem: Text {
                            text: Icons.layout // Hamburger menu replacement
                            font.family: Icons.font
                            font.pixelSize: 20
                            color: Colors.overBackground
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            color: parent.hovered ? Colors.surfaceBright : "transparent"
                            radius: Styling.radius(4)
                        }
                        
                        onClicked: root.sidebarExpanded = !root.sidebarExpanded
                    }
                    
                    Text {
                        text: Ai.currentModel.name
                        color: Colors.overBackground
                        font.family: Config.theme.font
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Status Indicator
                    Text {
                        text: Ai.isLoading ? "Thinking..." : "Ready"
                        color: Ai.isLoading ? Colors.primary : Colors.secondary
                        font.family: Config.theme.font
                        font.pixelSize: 12
                        visible: Ai.isLoading
                    }
                }
                
                // Messages
                ListView {
                    id: chatView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: Ai.currentChat
                    spacing: 16
                    displayMarginBeginning: 40
                    displayMarginEnd: 40
                    
                    // Auto scroll to bottom
                    onCountChanged: {
                        Qt.callLater(() => {
                            positionViewAtEnd();
                        });
                    }
                    
                    delegate: Item {
                        width: chatView.width
                        height: bubble.height + 20
                        
                        property bool isUser: modelData.role === "user"
                        
                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 10
                            layoutDirection: isUser ? Qt.RightToLeft : Qt.LeftToRight
                            spacing: 10
                            
                            // Icon
                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: isUser ? Colors.primary : Colors.secondary
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: isUser ? Icons.user : Icons.assistant
                                    font.family: Icons.font
                                    color: isUser ? Colors.overPrimary : Colors.overSecondary
                                }
                            }
                            
                            // Bubble
                            StyledRect {
                                id: bubble
                                variant: isUser ? "primaryContainer" : "surfaceVariant"
                                radius: Styling.radius(12)
                                
                                // Auto-sizing logic
                                width: Math.min(msgContent.implicitWidth + 24, chatView.width * 0.7)
                                height: msgContent.implicitHeight + 24
                                
                                TextEdit {
                                    id: msgContent
                                    anchors.centerIn: parent
                                    width: parent.width - 24
                                    text: modelData.content
                                    textFormat: Text.MarkdownText
                                    color: isUser ? Colors.overPrimaryContainer : Colors.overSurfaceVariant
                                    font.family: Config.theme.font
                                    font.pixelSize: 14
                                    wrapMode: Text.Wrap
                                    readOnly: true
                                    selectByMouse: true
                                }
                            }
                        }
                    }
                }
                
                // Input Area
                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(150, Math.max(50, inputField.contentHeight + 24))
                    variant: "surface"
                    radius: Styling.radius(8)
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            
                            TextArea {
                                id: inputField
                                placeholderText: "Ask anything..."
                                color: Colors.overSurface
                                font.family: Config.theme.font
                                font.pixelSize: 14
                                wrapMode: Text.Wrap
                                background: null
                                selectByMouse: true
                                
                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Return && !(event.modifiers & Qt.ShiftModifier)) {
                                        event.accepted = true;
                                        if (inputField.text.trim() !== "") {
                                            Ai.sendMessage(inputField.text);
                                            inputField.text = "";
                                        }
                                    }
                                }
                            }
                        }
                        
                        Button {
                            Layout.alignment: Qt.AlignBottom
                            flat: true
                            width: 40
                            height: 40
                            enabled: !Ai.isLoading && inputField.text.trim() !== ""
                            
                            contentItem: Text {
                                text: Icons.arrowRight // Send icon
                                font.family: Icons.font
                                font.pixelSize: 18
                                color: enabled ? Colors.primary : Colors.surfaceDim
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.hovered && enabled ? Colors.surfaceBright : "transparent"
                                radius: Styling.radius(4)
                            }
                            
                            onClicked: {
                                Ai.sendMessage(inputField.text);
                                inputField.text = "";
                            }
                        }
                    }
                }
            }
        }
    }
}