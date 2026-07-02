import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    readonly property real calendarWidth: Kirigami.Units.gridUnit * 14.2
    readonly property real calendarHeight: Kirigami.Units.gridUnit * 10.7
    readonly property real calendarMinWidth: Kirigami.Units.gridUnit * 10.5
    readonly property real calendarMinHeight: Kirigami.Units.gridUnit * 8.0
    readonly property real calendarMaxWidth: Kirigami.Units.gridUnit * 44.5
    readonly property real calendarMaxHeight: Kirigami.Units.gridUnit * 32
    readonly property real calendarAspect: calendarWidth / calendarHeight

    preferredRepresentation: fullRepresentation
    switchWidth: Kirigami.Units.gridUnit * 3
    switchHeight: Kirigami.Units.gridUnit * 3
    Layout.minimumWidth: calendarMinWidth
    Layout.minimumHeight: calendarMinHeight
    Layout.preferredWidth: calendarWidth
    Layout.preferredHeight: calendarHeight
    Layout.maximumWidth: calendarMaxWidth
    Layout.maximumHeight: calendarMaxHeight
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property date today: new Date()
    property date visibleMonth: new Date(today.getFullYear(), today.getMonth(), 1)
    property bool calendarHovered: false
    property bool monthPickerOpen: false
    readonly property string selectedPreset: Plasmoid.configuration.themePreset || "default"
    readonly property var savedPreset: selectedPreset === "saved" ? activeSavedPreset() : ({})
    readonly property bool savedPresetActive: selectedPreset === "saved" && savedPreset.name !== undefined
    readonly property bool customPresetActive: selectedPreset === "custom"
    readonly property string requestedThemeMode: customPresetActive ? (Plasmoid.configuration.customThemeMode || "dark") : (Plasmoid.configuration.themeMode || "auto")
    readonly property string themePreset: savedPresetActive
        ? (savedPreset.themePreset || "default")
        : (customPresetActive ? (Plasmoid.configuration.customThemePreset || "default") : selectedPreset)
    readonly property string themeMode: themePreset !== "default" ? "dark" : requestedThemeMode
    readonly property bool transparentBackground: customPresetActive ? (Plasmoid.configuration.customTransparentBackground || false) : (Plasmoid.configuration.transparentBackground || false)
    readonly property real backgroundOpacity: customPresetActive
        ? (Plasmoid.configuration.customBackgroundOpacity === undefined ? 0.6 : Plasmoid.configuration.customBackgroundOpacity)
        : (Plasmoid.configuration.backgroundOpacity === undefined ? 1.0 : Plasmoid.configuration.backgroundOpacity)
    readonly property bool glassEffect: customPresetActive ? (Plasmoid.configuration.customGlassEffect || false) : (Plasmoid.configuration.glassEffect || false)
    readonly property real glassIntensity: customPresetActive
        ? (Plasmoid.configuration.customGlassIntensity === undefined ? 0.55 : Plasmoid.configuration.customGlassIntensity)
        : (Plasmoid.configuration.glassIntensity === undefined ? 0.55 : Plasmoid.configuration.glassIntensity)
    readonly property real glassTone: customPresetActive
        ? (Plasmoid.configuration.customGlassTone === undefined ? 0.0 : Plasmoid.configuration.customGlassTone)
        : (Plasmoid.configuration.glassTone === undefined ? 0.0 : Plasmoid.configuration.glassTone)
    readonly property string textContrast: customPresetActive
        ? (Plasmoid.configuration.customTextContrast || "auto")
        : (Plasmoid.configuration.textContrast || "auto")
    readonly property string timeLocaleName: Plasmoid.configuration.timeLocaleName || Qt.locale().name
    readonly property var calendarLocale: timeLocaleName.length > 0 ? Qt.locale(timeLocaleName) : Qt.locale()
    readonly property int firstDayOfWeek: localeFirstDay()
    readonly property int currentHour: today.getHours()

    readonly property bool nightTime: currentHour >= 18 || currentHour < 6
    readonly property bool darkTheme: themeMode === "dark" || (themeMode === "auto" && nightTime)

    readonly property real surfaceOpacity: glassEffect
        ? Math.max(0.0, Math.min(0.82, backgroundOpacity * (0.92 - glassIntensity * 0.44)))
        : (transparentBackground ? Math.max(0.0, Math.min(1.0, backgroundOpacity)) : 1.0)
    readonly property color cardColor: withAlpha(toneColor(paletteCard()), surfaceOpacity)
    readonly property color cardFill: cardColor
    readonly property color overlayCardColor: withAlpha(toneColor(paletteCard()), glassEffect ? Math.max(0.58, surfaceOpacity + 0.24) : Math.max(surfaceOpacity, 0.88))
    readonly property color glassHighlight: withAlpha(colorFromHex(glassTone >= 0 ? "#ffffff" : "#000000"), glassEffect ? backgroundOpacity * (0.08 + Math.abs(glassTone) * 0.10 + glassIntensity * 0.07) : 0)
    readonly property color cardBorder: "transparent"
    readonly property color effectiveCardBase: toneColor(paletteCard())
    readonly property color estimatedBackdrop: darkTheme ? colorFromHex("#15171b") : colorFromHex("#eef2f8")
    readonly property color readableBackground: mixColor(estimatedBackdrop, effectiveCardBase, surfaceOpacity)
    readonly property real readableBackgroundLuminance: luminance(readableBackground)
    readonly property color primaryText: adaptivePrimaryText()
    readonly property color weekDayText: adaptiveWeekDayText()
    readonly property color secondaryText: paletteAccent()
    readonly property color mutedText: adaptiveMutedText()
    readonly property color accentColor: paletteAccent()
    readonly property color accentText: "#ffffff"
    readonly property color hoverFill: withAlpha(paletteHover(), glassEffect || transparentBackground ? 0.72 : 1.0)
    readonly property color controlIconColor: primaryText

    Plasmoid.icon: "view-calendar"
    Plasmoid.title: i18n("Mini Calendar")

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.today = new Date()
    }

    function withAlpha(colorValue, alpha) {
        return Qt.rgba(colorValue.r, colorValue.g, colorValue.b, alpha)
    }

    function wallpaperItem() {
        var item = root.parent

        while (item) {
            try {
                if (item.layout && item.layout.containmentItem && item.layout.containmentItem.wallpaper) {
                    return item.layout.containmentItem.wallpaper
                }
            } catch (error) {
            }

            item = item.parent
        }

        return null
    }

    function savedPresets() {
        try {
            var parsed = JSON.parse(Plasmoid.configuration.savedPresetsJson || "[]")
            return Array.isArray(parsed) ? parsed : []
        } catch (error) {
            return []
        }
    }

    function activeSavedPreset() {
        var presets = savedPresets()
        var activeName = Plasmoid.configuration.activeSavedPresetName || ""

        for (var i = 0; i < presets.length; i++) {
            if (presets[i].name === activeName) {
                return presets[i]
            }
        }

        return presets.length > 0 ? presets[0] : ({})
    }

    function colorFromHex(hexValue) {
        var value = hexValue.charAt(0) === "#" ? hexValue.slice(1) : hexValue
        return Qt.rgba(
            parseInt(value.slice(0, 2), 16) / 255,
            parseInt(value.slice(2, 4), 16) / 255,
            parseInt(value.slice(4, 6), 16) / 255,
            1
        )
    }

    function mixColor(fromColor, toColor, amount) {
        var value = Math.max(0, Math.min(1, amount))
        return Qt.rgba(
            fromColor.r + (toColor.r - fromColor.r) * value,
            fromColor.g + (toColor.g - fromColor.g) * value,
            fromColor.b + (toColor.b - fromColor.b) * value,
            fromColor.a + (toColor.a - fromColor.a) * value
        )
    }

    function luminance(colorValue) {
        return 0.2126 * colorValue.r + 0.7152 * colorValue.g + 0.0722 * colorValue.b
    }

    function toneColor(colorValue) {
        if (!glassEffect || Math.abs(glassTone) < 0.01) {
            return colorValue
        }

        return glassTone > 0
            ? mixColor(colorValue, colorFromHex("#ffffff"), glassTone * 0.35)
            : mixColor(colorValue, colorFromHex("#000000"), Math.abs(glassTone) * 0.35)
    }

    function paletteCard() {
        if (themePreset === "dracula") {
            return colorFromHex("#282a36")
        } else if (themePreset === "nord") {
            return colorFromHex(darkTheme ? "#2e3440" : "#eceff4")
        } else if (themePreset === "gruvbox") {
            return colorFromHex(darkTheme ? "#282828" : "#fbf1c7")
        } else if (themePreset === "solarized") {
            return colorFromHex(darkTheme ? "#002b36" : "#fdf6e3")
        } else if (themePreset === "catppuccin") {
            return colorFromHex("#1e1e2e")
        } else if (themePreset === "tokyonight") {
            return colorFromHex("#1a1b26")
        } else if (themePreset === "everforest") {
            return colorFromHex("#2d353b")
        } else if (themePreset === "onedark") {
            return colorFromHex("#282c34")
        } else if (themePreset === "rosepine") {
            return colorFromHex("#191724")
        } else if (themePreset === "materialocean") {
            return colorFromHex("#0f111a")
        }

        return colorFromHex(darkTheme ? "#202124" : "#f9fafc")
    }

    function palettePrimaryText() {
        if (themePreset === "dracula") {
            return colorFromHex("#f8f8f2")
        } else if (themePreset === "nord") {
            return colorFromHex(darkTheme ? "#eceff4" : "#2e3440")
        } else if (themePreset === "gruvbox") {
            return colorFromHex(darkTheme ? "#ebdbb2" : "#3c3836")
        } else if (themePreset === "solarized") {
            return colorFromHex(darkTheme ? "#eee8d5" : "#073642")
        } else if (themePreset === "catppuccin") {
            return colorFromHex("#cdd6f4")
        } else if (themePreset === "tokyonight") {
            return colorFromHex("#c0caf5")
        } else if (themePreset === "everforest") {
            return colorFromHex("#d3c6aa")
        } else if (themePreset === "onedark") {
            return colorFromHex("#abb2bf")
        } else if (themePreset === "rosepine") {
            return colorFromHex("#e0def4")
        } else if (themePreset === "materialocean") {
            return colorFromHex("#c3e88d")
        }

        return colorFromHex(darkTheme ? "#f4f4f5" : "#20242c")
    }

    function adaptivePrimaryText() {
        var darkText = colorFromHex("#171a20")
        var lightText = colorFromHex("#f8f8f2")
        var paletteText = palettePrimaryText()
        var forceDark = textContrast === "high" && readableBackgroundLuminance > 0.42
        var forceLight = textContrast === "high" && readableBackgroundLuminance <= 0.42

        if (textContrast === "soft") {
            return readableBackgroundLuminance > 0.54
                ? mixColor(paletteText, darkText, 0.55)
                : mixColor(paletteText, lightText, 0.45)
        }

        if (forceDark || (textContrast === "auto" && readableBackgroundLuminance > 0.46)) {
            return mixColor(paletteText, darkText, 0.90)
        }

        if (forceLight || (textContrast === "auto" && readableBackgroundLuminance <= 0.46)) {
            return mixColor(paletteText, lightText, 0.88)
        }

        return paletteText
    }

    function adaptiveWeekDayText() {
        return textContrast === "soft"
            ? mixColor(primaryText, secondaryText, 0.08)
            : primaryText
    }

    function paletteMutedText() {
        if (themePreset === "dracula") {
            return colorFromHex("#6272a4")
        } else if (themePreset === "nord") {
            return colorFromHex(darkTheme ? "#81a1c1" : "#66768f")
        } else if (themePreset === "gruvbox") {
            return colorFromHex(darkTheme ? "#928374" : "#928374")
        } else if (themePreset === "solarized") {
            return colorFromHex(darkTheme ? "#839496" : "#93a1a1")
        } else if (themePreset === "catppuccin") {
            return colorFromHex("#7f849c")
        } else if (themePreset === "tokyonight") {
            return colorFromHex("#565f89")
        } else if (themePreset === "everforest") {
            return colorFromHex("#859289")
        } else if (themePreset === "onedark") {
            return colorFromHex("#5c6370")
        } else if (themePreset === "rosepine") {
            return colorFromHex("#908caa")
        } else if (themePreset === "materialocean") {
            return colorFromHex("#546e7a")
        }

        return colorFromHex(darkTheme ? "#737780" : "#9aa1ad")
    }

    function adaptiveMutedText() {
        var baseMuted = paletteMutedText()

        if (!transparentBackground && !glassEffect && surfaceOpacity > 0.95) {
            return baseMuted
        }

        var amount = textContrast === "high" ? 0.22 : (textContrast === "soft" ? 0.56 : 0.34)
        var readableMuted = mixColor(primaryText, readableBackground, amount)
        return mixColor(baseMuted, readableMuted, textContrast === "high" ? 0.90 : Math.max(0.68, 1.0 - surfaceOpacity))
    }

    function paletteAccent() {
        if (themePreset === "dracula") {
            return colorFromHex("#ff79c6")
        } else if (themePreset === "nord") {
            return colorFromHex("#bf616a")
        } else if (themePreset === "gruvbox") {
            return colorFromHex(darkTheme ? "#fb4934" : "#cc241d")
        } else if (themePreset === "solarized") {
            return colorFromHex("#dc322f")
        } else if (themePreset === "catppuccin") {
            return colorFromHex("#f38ba8")
        } else if (themePreset === "tokyonight") {
            return colorFromHex("#f7768e")
        } else if (themePreset === "everforest") {
            return colorFromHex("#e67e80")
        } else if (themePreset === "onedark") {
            return colorFromHex("#e06c75")
        } else if (themePreset === "rosepine") {
            return colorFromHex("#eb6f92")
        } else if (themePreset === "materialocean") {
            return colorFromHex("#ff5370")
        }

        return colorFromHex(darkTheme ? "#f04f58" : "#d73e48")
    }

    function paletteHover() {
        if (themePreset === "dracula") {
            return colorFromHex("#44475a")
        } else if (themePreset === "nord") {
            return colorFromHex(darkTheme ? "#3b4252" : "#d8dee9")
        } else if (themePreset === "gruvbox") {
            return colorFromHex(darkTheme ? "#3c3836" : "#ebdbb2")
        } else if (themePreset === "solarized") {
            return colorFromHex(darkTheme ? "#073642" : "#eee8d5")
        } else if (themePreset === "catppuccin") {
            return colorFromHex("#313244")
        } else if (themePreset === "tokyonight") {
            return colorFromHex("#24283b")
        } else if (themePreset === "everforest") {
            return colorFromHex("#343f44")
        } else if (themePreset === "onedark") {
            return colorFromHex("#353b45")
        } else if (themePreset === "rosepine") {
            return colorFromHex("#26233a")
        } else if (themePreset === "materialocean") {
            return colorFromHex("#1f2233")
        }

        return colorFromHex(darkTheme ? "#2d2f34" : "#eceff4")
    }

    function localeFirstDay() {
        if (timeLocaleName === "pt_BR") {
            return 0
        }

        return calendarLocale.firstDayOfWeek >= 7 ? 0 : calendarLocale.firstDayOfWeek
    }

    function weekDayInitial(day) {
        if (timeLocaleName === "pt_BR") {
            return ["D", "S", "T", "Q", "Q", "S", "S"][day]
        }

        var name = calendarLocale.dayName(day)
        if (name.length === 0 && day === 0) {
            name = calendarLocale.dayName(7)
        }

        return name.charAt(0).toUpperCase()
    }

    function shortWeekDay(index) {
        var day = (firstDayOfWeek + index) % 7
        return weekDayInitial(day)
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear()
            && a.getMonth() === b.getMonth()
            && a.getDate() === b.getDate()
    }

    function monthTitle(date) {
        return date.toLocaleDateString(calendarLocale, "MMMM").toUpperCase()
    }

    function monthShortTitle(monthIndex) {
        return new Date(visibleMonth.getFullYear(), monthIndex, 1)
            .toLocaleDateString(calendarLocale, "MMM")
            .toUpperCase()
    }

    function cellDate(index) {
        var first = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), 1)
        var offset = (first.getDay() - firstDayOfWeek + 7) % 7
        return new Date(visibleMonth.getFullYear(), visibleMonth.getMonth(), 1 - offset + index)
    }

    function previousMonth() {
        monthPickerOpen = false
        visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() - 1, 1)
    }

    function nextMonth() {
        monthPickerOpen = false
        visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() + 1, 1)
    }

    function previousYear() {
        visibleMonth = new Date(visibleMonth.getFullYear() - 1, visibleMonth.getMonth(), 1)
    }

    function nextYear() {
        visibleMonth = new Date(visibleMonth.getFullYear() + 1, visibleMonth.getMonth(), 1)
    }

    function selectMonth(monthIndex) {
        visibleMonth = new Date(visibleMonth.getFullYear(), monthIndex, 1)
        monthPickerOpen = false
    }

    function goToday() {
        today = new Date()
        visibleMonth = new Date(today.getFullYear(), today.getMonth(), 1)
        monthPickerOpen = false
    }

    compactRepresentation: Rectangle {
        implicitWidth: Kirigami.Units.gridUnit * 2.4
        implicitHeight: Kirigami.Units.gridUnit * 2.4
        radius: Kirigami.Units.largeSpacing
        color: root.cardColor
        border.width: 0

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: root.expanded = !root.expanded
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0

            Controls.Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.today.toLocaleDateString(Qt.locale(), "MMM")
                color: root.secondaryText
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                font.bold: true
            }

            Controls.Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.today.getDate()
                color: root.primaryText
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize + 4
                font.bold: true
            }
        }
    }

    fullRepresentation: Item {
        id: fullView

        readonly property real contentScale: Math.max(0.86, Math.min(width / root.calendarWidth, height / root.calendarHeight, 2.2))
        readonly property real marginSize: Kirigami.Units.largeSpacing * contentScale
        readonly property real smallGap: Kirigami.Units.smallSpacing * contentScale
        readonly property real cellSize: Kirigami.Units.gridUnit * contentScale
        readonly property real titleFontSize: Kirigami.Theme.defaultFont.pixelSize * contentScale
        readonly property real dayFontSize: Kirigami.Theme.smallFont.pixelSize * contentScale
        readonly property real iconSize: Kirigami.Units.iconSizes.small * contentScale

        implicitWidth: root.calendarWidth
        implicitHeight: root.calendarHeight
        Layout.minimumWidth: root.calendarMinWidth
        Layout.minimumHeight: root.calendarMinHeight
        Layout.preferredWidth: root.calendarWidth
        Layout.preferredHeight: root.calendarHeight
        Layout.maximumWidth: root.calendarMaxWidth
        Layout.maximumHeight: root.calendarMaxHeight

        ShaderEffectSource {
            id: desktopSource

            readonly property var sceneItem: root.wallpaperItem()

            width: fullView.width
            height: fullView.height
            live: root.glassEffect
            recursive: false
            visible: false
            sourceItem: sceneItem
            sourceRect: {
                if (!sceneItem) {
                    return Qt.rect(0, 0, width, height)
                }

                var position = fullView.mapToItem(sceneItem, 0, 0)
                return Qt.rect(position.x, position.y, fullView.width, fullView.height)
            }
        }

        Item {
            id: glassBlurLayer

            anchors.fill: parent
            visible: root.glassEffect && desktopSource.sceneItem
            layer.enabled: visible
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: glassBlurLayer.width
                    height: glassBlurLayer.height
                    radius: Kirigami.Units.gridUnit * 0.85 * fullView.contentScale
                }
            }

            FastBlur {
                anchors.fill: parent
                source: desktopSource
                radius: Math.max(8, 42 * root.glassIntensity)
                transparentBorder: true
            }
        }

        Rectangle {
            id: calendarCard
            anchors.fill: parent
            radius: Kirigami.Units.gridUnit * 0.85 * fullView.contentScale
            color: root.cardFill
            border.color: root.cardBorder
            border.width: 0
        }

        Rectangle {
            anchors.fill: calendarCard
            radius: calendarCard.radius
            color: root.glassHighlight
            visible: root.glassEffect
        }

        HoverHandler {
            onHoveredChanged: root.calendarHovered = hovered
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: fullView.marginSize
            spacing: fullView.smallGap
            visible: !root.monthPickerOpen

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.gridUnit * 0.5 * fullView.contentScale
                Layout.rightMargin: Kirigami.Units.gridUnit * 0.25 * fullView.contentScale
                Layout.topMargin: fullView.smallGap
                Layout.bottomMargin: fullView.smallGap * 0.5
                spacing: 0

                Controls.Label {
                    Layout.fillWidth: true
                    text: root.monthTitle(root.visibleMonth)
                    color: root.secondaryText
                    horizontalAlignment: Text.AlignLeft
                    font.bold: true
                    font.pixelSize: fullView.titleFontSize
                }

                RowLayout {
                    opacity: root.calendarHovered || root.monthPickerOpen ? 1 : 0
                    visible: opacity > 0
                    spacing: fullView.smallGap

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: fullView.cellSize
                        Layout.preferredWidth: fullView.cellSize
                        radius: width / 2
                        color: pickerMouseArea.containsMouse ? root.hoverFill : "transparent"

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            source: "view-grid"
                            color: root.controlIconColor
                            implicitWidth: fullView.iconSize
                            implicitHeight: fullView.iconSize
                        }

                        MouseArea {
                            id: pickerMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.monthPickerOpen = !root.monthPickerOpen
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: fullView.cellSize
                        Layout.preferredHeight: fullView.cellSize
                        radius: width / 2
                        color: previousMonthMouseArea.containsMouse ? root.hoverFill : "transparent"

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            source: "go-previous"
                            color: root.controlIconColor
                            implicitWidth: fullView.iconSize
                            implicitHeight: fullView.iconSize
                        }

                        MouseArea {
                            id: previousMonthMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.previousMonth()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: fullView.cellSize
                        Layout.preferredHeight: fullView.cellSize
                        radius: width / 2
                        color: nextMonthMouseArea.containsMouse ? root.hoverFill : "transparent"

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            source: "go-next"
                            color: root.controlIconColor
                            implicitWidth: fullView.iconSize
                            implicitHeight: fullView.iconSize
                        }

                        MouseArea {
                            id: nextMonthMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.nextMonth()
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                rowSpacing: 0
                columnSpacing: 0

                Repeater {
                    model: 49

                    Item {
                        required property int index
                        readonly property bool headerCell: index < 7
                        property date dateValue: root.cellDate(index - 7)
                        readonly property bool currentMonth: !headerCell && dateValue.getMonth() === root.visibleMonth.getMonth()
                        readonly property bool isToday: !headerCell && root.sameDay(dateValue, root.today)

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: fullView.cellSize
                        Layout.preferredHeight: fullView.cellSize

                        Rectangle {
                            id: dayBubble

                            visible: parent.isToday || mouseArea.containsMouse
                            anchors.centerIn: parent
                            width: parent.isToday ? fullView.cellSize * 0.82 : fullView.cellSize * 0.92
                            height: width
                            radius: width / 2
                            color: parent.isToday ? root.accentColor : root.hoverFill
                        }

                        Controls.Label {
                            anchors.centerIn: parent.isToday ? dayBubble : parent
                            width: parent.isToday ? dayBubble.width : parent.width
                            height: parent.isToday ? dayBubble.height : parent.height
                            text: parent.headerCell ? root.shortWeekDay(parent.index) : parent.dateValue.getDate()
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: parent.headerCell
                                ? root.weekDayText
                                : (parent.isToday ? root.accentText : (parent.currentMonth ? root.primaryText : root.mutedText))
                            font.bold: parent.headerCell || parent.isToday
                            font.pixelSize: fullView.dayFontSize
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            hoverEnabled: true
                        }
                    }
                }
            }
        }

        Rectangle {
            id: monthPicker
            anchors.fill: parent
            radius: calendarCard.radius
            color: root.overlayCardColor
            border.color: root.cardBorder
            border.width: 0
            visible: root.monthPickerOpen
            z: 10

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: root.glassHighlight
                visible: root.glassEffect
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: fullView.marginSize
                spacing: fullView.smallGap

                RowLayout {
                    Layout.fillWidth: true
                    spacing: fullView.smallGap

                    Rectangle {
                        Layout.preferredWidth: fullView.cellSize * 1.25
                        Layout.preferredHeight: fullView.cellSize * 1.25
                        radius: width / 2
                        color: previousYearMouseArea.containsMouse ? root.hoverFill : "transparent"

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            source: "go-previous"
                            color: root.primaryText
                            implicitWidth: fullView.iconSize
                            implicitHeight: fullView.iconSize
                        }

                        MouseArea {
                            id: previousYearMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.previousYear()
                        }
                    }

                    Controls.Label {
                        Layout.fillWidth: true
                        text: root.visibleMonth.getFullYear()
                        color: root.primaryText
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        font.pixelSize: fullView.titleFontSize
                    }

                    Rectangle {
                        Layout.preferredWidth: fullView.cellSize * 1.25
                        Layout.preferredHeight: fullView.cellSize * 1.25
                        radius: width / 2
                        color: nextYearMouseArea.containsMouse ? root.hoverFill : "transparent"

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            source: "go-next"
                            color: root.primaryText
                            implicitWidth: fullView.iconSize
                            implicitHeight: fullView.iconSize
                        }

                        MouseArea {
                            id: nextYearMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.nextYear()
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3
                    rowSpacing: fullView.smallGap
                    columnSpacing: fullView.smallGap

                    Repeater {
                        model: 12

                        Rectangle {
                            required property int index
                            readonly property bool selectedMonth: index === root.visibleMonth.getMonth()

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: fullView.smallGap
                            color: selectedMonth ? root.accentColor : (monthMouseArea.containsMouse ? root.hoverFill : "transparent")

                            Controls.Label {
                                anchors.centerIn: parent
                                text: root.monthShortTitle(parent.index)
                                color: parent.selectedMonth ? root.accentText : root.primaryText
                                font.bold: parent.selectedMonth
                                font.pixelSize: fullView.dayFontSize
                            }

                            MouseArea {
                                id: monthMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.selectMonth(parent.index)
                            }
                        }
                    }
                }

                Rectangle {
                    id: todayButton

                    Layout.fillWidth: true
                    Layout.preferredHeight: fullView.cellSize * 1.35
                    radius: fullView.smallGap
                    color: todayMouseArea.containsMouse ? root.hoverFill : (root.darkTheme ? "#2f3137" : "#e9edf3")

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: fullView.smallGap

                        Kirigami.Icon {
                            source: "go-jump-today"
                            color: root.accentColor
                            implicitWidth: fullView.iconSize
                            implicitHeight: fullView.iconSize
                        }

                        Controls.Label {
                            text: i18n("Hoje")
                            color: root.primaryText
                            font.bold: true
                            font.pixelSize: fullView.dayFontSize
                        }
                    }

                    MouseArea {
                        id: todayMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.goToday()
                    }
                }
            }
        }
    }
}
