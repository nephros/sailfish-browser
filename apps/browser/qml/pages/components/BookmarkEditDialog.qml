/****************************************************************************
**
** Copyright (c) 2014 Jolla Ltd.
** Contact: Vesa-Matti Hartikainen <vesa-matti.hartikainen@jolla.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.WebView.Popups 1.0

UserPromptDialog {
    id: root

    property string url
    property string title
    property string favicon
    property string thumbnail
    property int index
    property string description

    property alias editedUrl: urlField.text
    property alias editedTitle: titleField.text

    property var iconData

    canAccept: urlField.acceptableInput && titleField.acceptableInput

    onAcceptBlocked: {
        if (!titleField.acceptableInput) {
            titleField.errorHighlight = true
        }

        if (!urlField.acceptableInput) {
            urlField.errorHighlight = true
        }
    }

    //% "Edit"
    title: qsTrId("sailfish_browser-he-edit")

    //: Accept text of bookmark edit dialog
    //% "Save"
    acceptText: qsTrId("sailfish_browser-la-accept_edit")

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn

            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader {
                dialog: root
                _glassOnly: true
                acceptText: root.acceptText
                cancelText: root.cancelText
                title: root.description
            }

            TextField {
                id: titleField

                text: title
                focus: true

                acceptableInput: text.length > 0
                onActiveFocusChanged: if (!activeFocus) errorHighlight = !acceptableInput
                onAcceptableInputChanged: if (acceptableInput) errorHighlight = false

                //: Label for bookmark/favorite's title edit field
                //% "Title"
                label: qsTrId("sailfish_browser-la-title_editor")
                //% "Title is required"
                description: errorHighlight ? qsTrId("sailfish_browser-la-title_editor_error") : ""

                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: urlField.focus = true
            }

            TextField {
                id: urlField

                text: url
                onActiveFocusChanged: if (!activeFocus) errorHighlight = !acceptableInput
                onAcceptableInputChanged: if (acceptableInput) errorHighlight = false

                //: Label for textfield to edit bookmark's URL
                //% "URL"
                label: qsTrId("sailfish_browser-la-url_editor")
                description: {
                    if (!errorHighlight) {
                        return ""
                    } else if (text.length > 0) {
                        var scheme = root.url.match(/^(https?):\/\/.+/)

                        //% "URL scheme (%1) missing"
                        return qsTrId("sailfish_browser-la-missing_url_scheme").arg(scheme && scheme.length > 1
                                                                                    ? scheme[1] : "https")
                    } else {
                        //% "URL is required"
                        return qsTrId("sailfish_browser-la-url_editor_error")
                    }
                }
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly

                EnterKey.enabled: canAccept
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: accept()

                validator: RegExpValidator {
                    regExp: /^https?:\/\/.+/
                }
            }
            Label { width: parent.width
                text:  "fav: " + favicon + "\nthumb: " + thumbnail + "\ndefault: default" + "\nimagedata: " + root.iconData
            }
            SectionHeader {
                //% "Grid Icon"
                text: qsTrId("sailfish_browser-la-url_editor_icon")
            }
            BackgroundItem {
                id: faviconMaker
                // fixed application grid icon size, so we can grabToImage() correctly
                height: 256; width: 256
                anchors.horizontalCenter: parent.horizontalCenter
                property alias image: image
                Image {
                    id: image
                    anchors.centerIn: parent
                    anchors.fill: parent
                    property bool wantGrab
                    onSourceChanged: {
                        wantGrab = /^https?:\/\//.test(source)
                        console.warn("Source changed, grab:", wantGrab)
                    }
                    source: {
                        if (favicon)   return favicon
                        if (thumbnail) return thumbnail
                        return "image://theme/icon-launcher-bookmark"
                    }
                    Connections {
                        target: root
                        onAcceped: {
                            if (wantGrab && image.status === Image.Ready) {
                                console.warn("Grabbing Image:")
                                image.grabToImage(
                                    function(result) {
                                        var filePath = StandardPaths.cache + "/" + "appthumb-" + Qt.md5(Date.now() + result.url) + ".png"
                                        var ok = result.saveToFile(filePath)
                                        console.warn("Image saved:", ok, filePath)
                                        root.iconData = ok ? filePath : "icon-launcher-bookmark"
                                    }, Qt.size(256, 256)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
