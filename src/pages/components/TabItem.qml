/****************************************************************************
**
** Copyright (C) 2014 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jolla.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.1
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    readonly property bool activeTab: activeTabIndex === index
    // Expose ListView for all items
    property Item view: GridView.view
    property real topMargin
    property real leftMargin
    property real rightMargin

    layer.effect: PressEffect {}
    layer.enabled: _showPress
    contentItem.visible: false
    contentItem.color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
    contentItem.radius: 2/3 * Theme.paddingMedium
    contentItem.anchors {
        fill: root
        topMargin: root.topMargin
        leftMargin: root.leftMargin
        rightMargin: root.rightMargin
        bottomMargin: Theme.paddingMedium
    }

    onClicked: view.activateTab(index)

    data: [
        Image {
            id: image

            readonly property bool active: source != ""

            source: !activeTab ? thumbnailPath : ""
            cache: false
            visible: false
            asynchronous: true
            smooth: true
        },

        ShaderEffectSource {
            id: textureSource
            anchors.fill: parent
            visible: false
            sourceItem: activeTab ? activeWebPage : (image.active ? image : contentItem)
            sourceRect: Qt.rect(0, 0, mask.width, mask.height)
        },

        ShaderEffectSource {
            id: mask
            anchors.fill: contentItem
            hideSource: true
            visible: false
            sourceItem: Rectangle {
                x: contentItem.x
                y: contentItem.y
                width: contentItem.width
                height: contentItem.height
                radius: contentItem.radius
                color: "white"
            }
        },

        ShaderEffect {
            id: roundingItem
            property variant source: textureSource
            property variant maskSource: mask

            anchors.fill: mask
            smooth: true

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform highp float qt_Opacity;
                uniform lowp sampler2D source;
                uniform lowp sampler2D maskSource;
                void main(void) {
                    gl_FragColor = texture2D(source, qt_TexCoord0.st) * (texture2D(maskSource, qt_TexCoord0.st).a) * qt_Opacity;
                }"
        },

        OpacityRampEffect {
            slope: 2.6
            offset: 0.6
            //        slope: slope.value
            //        offset: offset.value

            sourceItem: roundingItem
            anchors.fill: mask
            direction: OpacityRamp.TopToBottom
        },

        // Debug slider for opacity ramp
        //    Column {
        //        anchors.top: parent.top
        //        anchors.topMargin: 20
        //        width: parent.width
        //        spacing: 20
        //        Slider {
        //            id: slope
        //            width: parent.width
        //            value: 2.6
        //            stepSize: 0.02
        //            minimumValue: 0.5
        //            maximumValue: 10.0
        //            valueText: value
        //        }

        //        Slider {
        //            id: offset
        //            width: parent.width
        //            value: 0.6
        //            stepSize: 0.01
        //            valueText: value
        //        }
        //    }

        IconButton {
            id: close

            anchors {
                left: mask.left
                bottom: parent.bottom
                bottomMargin: -Theme.paddingMedium
            }
            icon.source: "image://theme/icon-m-tab-close"
            onClicked: {
                activeTabIndex = -1
                view.closeTab(index)
            }
        },

        Label {
            anchors {
                left: close.right
                right: mask.right
                rightMargin: Theme.paddingMedium
                verticalCenter: close.verticalCenter
            }

            text: title
            truncationMode: TruncationMode.Fade
            color: down ? Theme.highlightColor : Theme.primaryColor
        }
    ]
}
