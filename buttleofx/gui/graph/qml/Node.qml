import QtQuick 2.0
import QuickMamba 1.0

Rectangle {
    id: qml_nodeRoot

    property variant graphRoot

    QtObject {
        id: m
        property variant nodeModel: model.object
        property variant nodeRoot: qml_nodeRoot
    }

    x: m.nodeModel.coord.x
    y: m.nodeModel.coord.y
    z: _buttleData.graphWrapper.zMax

    height: m.nodeModel.height
    width: m.nodeModel.width

    Component.onCompleted: {
        // console.log("Node: ", objectName)
        m.nodeModel.fitWidth(nodeText.width)
        // _buttleData.graphWrapper.updateConnectionsCoord(m.nodeModel);
    }

    property int inputSpacing : m.nodeModel.clipSpacing
    property int clipSize: m.nodeModel.clipSize
    property int nbInput: m.nodeModel.nbInput
    property int inputTopMargin: m.nodeModel.inputTopMargin
    property int outputTopMargin: m.nodeModel.outputTopMargin
    property int sideMargin: m.nodeModel.sideMargin

    signal drawSelection(int x, int y, int width, int height)

    color: "transparent"
    focus: true

    MouseArea {
        id: nodeMouseArea
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XandYAxis
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: {
            // left button : we change the current selected nodes & we start moving
            if (mouse.button == Qt.LeftButton) {

                // we clear the list of selected connections
                _buttleData.clearCurrentConnectionId()

                // if the Control Key is not pressed, we clear the list of selected nodes
                if (!(mouse.modifiers & Qt.ControlModifier)) {
                    _buttleData.clearCurrentSelectedNodeNames()
                }

                // we add the node to the list of selected nodes (if it's not already selected)
                if(!_buttleData.nodeIsSelected(m.nodeModel)) {
                    _buttleData.appendToCurrentSelectedNodeWrappers(m.nodeModel)
                }

                _buttleData.graphWrapper.zMax += 1
                parent.z = _buttleData.graphWrapper.zMax
                stateMoving.state = "moving"
            }

            // right button : we change the current param node
           else if (mouse.button == Qt.RightButton) {
                // here display contextual menu
            }

            // take the focus
            m.nodeRoot.forceActiveFocus()
        }
        onReleased: {
            // left button : we end moving
            if (mouse.button == Qt.LeftButton) {
                _buttleManager.nodeManager.nodeMoved(m.nodeModel.name, parent.x, parent.y)
                stateMoving.state = "normal"
            }
        }

        // double click : we change the current param node
        onDoubleClicked: {
            _buttleData.currentParamNodeWrapper = m.nodeModel;
        }

    }

    ExternDropArea {
        anchors.fill: parent
        onDragEnter: {
            acceptDrop = hasText && text=="mosquito_of_the_dead";
        }
        onDrop: {
            if (acceptDrop) {
                _buttleData.currentViewerNodeWrapper = m.nodeModel;
                _buttleData.currentViewerFrame = 0;
                // we assign the node to the viewer, at the frame 0
                _buttleData.assignNodeToViewerIndex(m.nodeModel, 0);
                _buttleEvent.emitViewerChangedSignal()
            }
        }
    }

    Rectangle {
        id: nodeBorder
        anchors.centerIn: parent
        radius: 10
        state: "normal"

        StateGroup {
            id: stateParamNode
             states: [
                 State {
                     name: "normal"
                     when: m.nodeModel != _buttleData.currentParamNodeWrapper
                     PropertyChanges {
                         target: nodeBorder
                         height: parent.height
                         width: parent.width
                         color:  m.nodeModel.color
                         opacity: 0.5
                     }
                 },
                 State {
                     name: "currentParamNode"
                     when: m.nodeModel == _buttleData.currentParamNodeWrapper
                     PropertyChanges {
                         target: nodeBorder;
                         height: parent.height
                         width: parent.width
                         color:  m.nodeModel.color
                         opacity: 1;
                     }
                 }
             ]
        }
    }

    Rectangle {
        id: nodeRectangle
        anchors.centerIn: parent
        anchors.fill: parent
        anchors.margins: 4
        color: "#bbbbbb"
        radius: 8
        Text {
            id: nodeText
            anchors.centerIn: parent
            text: m.nodeModel.nameUser
            font.pointSize: 10
            property bool isSelected: _buttleData.nodeIsSelected(m.nodeModel)
            
            onTextChanged: {
                m.nodeModel.fitWidth(nodeText.width);
                // _buttleData.graphWrapper.updateConnectionsCoord(m.nodeModel);
            }

            Connections {
                target: _buttleData
                onCurrentSelectedNodeWrappersChanged: {
                    nodeText.isSelected = _buttleData.nodeIsSelected(m.nodeModel)
                }
            }
            color: isSelected ? m.nodeModel.color : "black"
        }
    }
    // inputClips
    Column {
        id: nodeInputs
        // anchors.left: parent.left
        anchors.leftMargin: -m.nodeRoot.sideMargin
        // anchors.top: parent.top
        anchors.topMargin: m.nodeRoot.inputTopMargin
        anchors.fill: parent
        spacing: m.nodeRoot.inputSpacing
        Repeater {
            model: m.nodeModel.srcClips
            Clip {
                id: in_clip
                clipWrapper: model.object
                port: "input"
                graphRoot: m.nodeRoot.graphRoot
                nodeRoot: m.nodeRoot
            }
        }
    }
    // outputClip
    Column {
        id: nodeOutputs
        anchors.right: parent.right
        anchors.rightMargin: -m.nodeRoot.sideMargin
        anchors.top : parent.top
        anchors.topMargin: m.nodeRoot.outputTopMargin
        width: 1
        height: 1
        // always only one outputClip
        Clip {
            id: out_clip
            clipWrapper: m.nodeModel.outputClip
            port: "output"
            graphRoot: m.nodeRoot.graphRoot
            nodeRoot: m.nodeRoot
        }
    }

    Rectangle {
        id: deadMosquito
        width: 23
        height: 21
        x: m.nodeRoot.width - 12
        y: -10
        state: "normal"
        color: "transparent"

        Image {
                id: deadMosquitoImage
                anchors.fill: parent
             }

        StateGroup {
            id: stateViewerNode
             states: [
                 State {
                     name: "normal"
                     when: m.nodeModel != _buttleData.currentViewerNodeWrapper
                     PropertyChanges {
                         target: deadMosquitoImage;
                         source: ""
                     }
                 },
                 State {
                     name: "currentViewerNode"
                     when: m.nodeModel == _buttleData.currentViewerNodeWrapper
                     PropertyChanges {
                         target: deadMosquitoImage;
                         source: "file///" + _buttleData.buttlePath + "/gui/img/mosquito/mosquito_dead.png"
                     }
                 }
             ]
        }
    }

    StateGroup {
        id: stateMoving
        state: "normal"
        states: [
            State {
                name: "normal"
                PropertyChanges { target: m.nodeRoot; x: m.nodeModel.coord.x; y: m.nodeModel.coord.y }
            },
            State {
                name: "moving"
                PropertyChanges { target: m.nodeRoot; x: m.nodeModel.coord.x ; y: m.nodeModel.coord.y }
            }
        ]
    }

    StateGroup {
        id: statePressed
        states: [
            State {
            name: "pressed"
            when: nodeMouseArea.pressed
            PropertyChanges { target: m.nodeRoot; opacity: .5 }
            }
        ]
    }

    onXChanged: {
        if (nodeMouseArea.drag.active) {
            m.nodeRoot.nodeIsMoving()
        }
    }
    onYChanged: {
        if (nodeMouseArea.drag.active) {
            m.nodeRoot.nodeIsMoving()
        }
    }

    function nodeIsMoving() {
        _buttleManager.nodeManager.nodeIsMoving(m.nodeModel.name, m.nodeRoot.x, m.nodeRoot.y)
    }
}
