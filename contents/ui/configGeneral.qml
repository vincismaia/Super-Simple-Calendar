import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_themeMode: themeMode.currentValue
    property alias cfg_themePreset: themePreset.currentValue
    property alias cfg_transparentBackground: transparentBackground.checked
    property alias cfg_backgroundOpacity: backgroundOpacity.value
    property alias cfg_glassEffect: glassEffect.checked
    property alias cfg_glassIntensity: glassIntensity.value
    property alias cfg_glassTone: glassTone.value
    property alias cfg_textContrast: textContrast.currentValue
    property string cfg_savedPresetsJson: "[]"
    property string cfg_activeSavedPresetName: ""
    property string cfg_customThemePreset: "default"
    property string cfg_customThemeMode: "dark"
    property bool cfg_customTransparentBackground: true
    property real cfg_customBackgroundOpacity: 0.6
    property bool cfg_customGlassEffect: true
    property real cfg_customGlassIntensity: 0.55
    property real cfg_customGlassTone: 0.35
    property string cfg_customTextContrast: "auto"
    property string cfg_timeLocaleName: "pt_BR"
    property string cfg_themeModeDefault: "auto"
    property string cfg_themePresetDefault: "default"
    property string cfg_customThemePresetDefault: "default"
    property string cfg_customThemeModeDefault: "dark"
    property bool cfg_customTransparentBackgroundDefault: true
    property real cfg_customBackgroundOpacityDefault: 0.6
    property bool cfg_customGlassEffectDefault: true
    property real cfg_customGlassIntensityDefault: 0.55
    property real cfg_customGlassToneDefault: 0.35
    property string cfg_customTextContrastDefault: "auto"
    property bool cfg_transparentBackgroundDefault: false
    property real cfg_backgroundOpacityDefault: 1.0
    property bool cfg_glassEffectDefault: false
    property real cfg_glassIntensityDefault: 0.55
    property real cfg_glassToneDefault: 0.0
    property string cfg_textContrastDefault: "auto"
    property string cfg_savedPresetsJsonDefault: "[]"
    property string cfg_activeSavedPresetNameDefault: ""
    property string cfg_timeLocaleNameDefault: "pt_BR"
    property string title: i18n("Appearance")
    property var savedPresetModel: buildSavedPresetModel()

    onCfg_savedPresetsJsonChanged: savedPresetModel = buildSavedPresetModel()

    function selectPreset(value) {
        for (var i = 0; i < themePreset.model.length; i++) {
            if (themePreset.model[i].value === value) {
                themePreset.currentIndex = i
                return
            }
        }
    }

    function selectThemeMode(value) {
        for (var i = 0; i < themeMode.model.length; i++) {
            if (themeMode.model[i].value === value) {
                themeMode.currentIndex = i
                return
            }
        }
    }

    function builtInPreset(value) {
        return value !== "default" && value !== "saved" && value !== "custom"
    }

    function savedPresets() {
        try {
            var parsed = JSON.parse(cfg_savedPresetsJson || "[]")
            return Array.isArray(parsed) ? parsed : []
        } catch (error) {
            return []
        }
    }

    function buildSavedPresetModel() {
        var presets = savedPresets()
        var model = []

        for (var i = 0; i < presets.length; i++) {
            model.push({
                text: presets[i].name,
                value: presets[i].name
            })
        }

        return model
    }

    function activeSavedPreset() {
        var presets = savedPresets()

        for (var i = 0; i < presets.length; i++) {
            if (presets[i].name === cfg_activeSavedPresetName) {
                return presets[i]
            }
        }

        return presets.length > 0 ? presets[0] : null
    }

    function loadSavedPreset(preset) {
        if (!preset) {
            return
        }

        selectThemeMode(preset.themeMode || "dark")
        transparentBackground.checked = !!preset.transparentBackground
        backgroundOpacity.value = preset.backgroundOpacity === undefined ? 0.6 : preset.backgroundOpacity
        glassEffect.checked = !!preset.glassEffect
        glassIntensity.value = preset.glassIntensity === undefined ? 0.55 : preset.glassIntensity
        glassTone.value = preset.glassTone === undefined ? 0.0 : preset.glassTone
        selectTextContrast(preset.textContrast || "auto")
    }

    function selectSavedPresetByName(name) {
        var presets = savedPresets()

        for (var i = 0; i < presets.length; i++) {
            if (presets[i].name === name) {
                cfg_activeSavedPresetName = name
                loadSavedPreset(presets[i])
                selectPreset("saved")
                return
            }
        }
    }

    function loadCustomPreset() {
        selectThemeMode(cfg_customThemeMode)
        transparentBackground.checked = cfg_customTransparentBackground
        backgroundOpacity.value = cfg_customBackgroundOpacity
        glassEffect.checked = cfg_customGlassEffect
        glassIntensity.value = cfg_customGlassIntensity
        glassTone.value = cfg_customGlassTone
        selectTextContrast(cfg_customTextContrast)
    }

    function saveCustomPreset() {
        var presetName = presetNameField.text.trim()
        var basePreset = themePreset.currentValue === "saved" ? "default" : themePreset.currentValue
        var presets = savedPresets()
        var saved = {
            name: presetName.length > 0 ? presetName : i18n("My preset"),
            themePreset: basePreset === "custom" ? cfg_customThemePreset : basePreset,
            themeMode: builtInPreset(basePreset) ? "dark" : themeMode.currentValue,
            transparentBackground: transparentBackground.checked,
            backgroundOpacity: backgroundOpacity.value,
            glassEffect: glassEffect.checked,
            glassIntensity: glassIntensity.value,
            glassTone: glassTone.value,
            textContrast: textContrast.currentValue
        }
        var replaced = false

        for (var i = 0; i < presets.length; i++) {
            if (presets[i].name === saved.name) {
                presets[i] = saved
                replaced = true
                break
            }
        }

        if (!replaced) {
            presets.push(saved)
        }

        cfg_savedPresetsJson = JSON.stringify(presets)
        cfg_activeSavedPresetName = saved.name
        savedPresetModel = buildSavedPresetModel()
        selectPreset("saved")
    }

    function deleteActiveSavedPreset() {
        var presets = savedPresets()
        var kept = []

        for (var i = 0; i < presets.length; i++) {
            if (presets[i].name !== cfg_activeSavedPresetName) {
                kept.push(presets[i])
            }
        }

        cfg_savedPresetsJson = JSON.stringify(kept)
        cfg_activeSavedPresetName = kept.length > 0 ? kept[0].name : ""
        savedPresetModel = buildSavedPresetModel()

        if (kept.length > 0) {
            loadSavedPreset(kept[0])
        } else {
            selectPreset("default")
        }
    }

    function saveLegacyCustomPreset() {
        cfg_customThemePreset = themePreset.currentValue === "custom" ? cfg_customThemePreset : themePreset.currentValue
        cfg_customThemeMode = themeMode.currentValue
        cfg_customTransparentBackground = transparentBackground.checked
        cfg_customBackgroundOpacity = backgroundOpacity.value
        cfg_customGlassEffect = glassEffect.checked
        cfg_customGlassIntensity = glassIntensity.value
        cfg_customGlassTone = glassTone.value
        cfg_customTextContrast = textContrast.currentValue
        selectPreset("custom")
    }

    function selectTextContrast(value) {
        for (var i = 0; i < textContrast.model.length; i++) {
            if (textContrast.model[i].value === value) {
                textContrast.currentIndex = i
                return
            }
        }
    }

    Controls.ComboBox {
        id: themeMode
        Kirigami.FormData.label: i18n("Theme:")
        enabled: !page.builtInPreset(themePreset.currentValue)
        textRole: "text"
        valueRole: "value"
        model: [
            { text: i18n("Automatic"), value: "auto" },
            { text: i18n("Light"), value: "light" },
            { text: i18n("Dark"), value: "dark" }
        ]
    }

    Controls.ComboBox {
        id: themePreset
        Kirigami.FormData.label: i18n("Preset:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: i18n("Default"), value: "default" },
            { text: i18n("Dracula"), value: "dracula" },
            { text: i18n("Nord"), value: "nord" },
            { text: i18n("Gruvbox"), value: "gruvbox" },
            { text: i18n("Solarized"), value: "solarized" },
            { text: i18n("Saved preset"), value: "saved" }
        ]
        onActivated: {
            if (page.builtInPreset(currentValue)) {
                page.selectThemeMode("dark")
            } else if (currentValue === "saved") {
                page.loadSavedPreset(page.activeSavedPreset())
            }
        }
    }

    Controls.ComboBox {
        id: savedPresetSelector
        Kirigami.FormData.label: i18n("Saved:")
        enabled: page.savedPresetModel.length > 0
        visible: themePreset.currentValue === "saved"
        textRole: "text"
        valueRole: "value"
        model: page.savedPresetModel
        onActivated: page.selectSavedPresetByName(currentValue)
        Component.onCompleted: {
            for (var i = 0; i < model.length; i++) {
                if (model[i].value === page.cfg_activeSavedPresetName) {
                    currentIndex = i
                    break
                }
            }
        }
    }

    Controls.TextField {
        id: presetNameField
        Kirigami.FormData.label: i18n("Name:")
        text: page.cfg_activeSavedPresetName.length > 0 ? page.cfg_activeSavedPresetName : i18n("My preset")
        placeholderText: i18n("Preset name")
    }

    Controls.Button {
        Kirigami.FormData.label: i18n("Presets:")
        text: i18n("Save preset")
        icon.name: "document-save"
        onClicked: page.saveCustomPreset()
    }

    Controls.Button {
        text: i18n("Delete saved preset")
        icon.name: "edit-delete"
        enabled: themePreset.currentValue === "saved" && page.savedPresetModel.length > 0
        onClicked: page.deleteActiveSavedPreset()
    }

    Controls.CheckBox {
        id: transparentBackground
        Kirigami.FormData.label: i18n("Background:")
        text: i18n("Transparent")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Opacity:")
        enabled: transparentBackground.checked || glassEffect.checked

        Controls.Slider {
            id: backgroundOpacity
            Layout.fillWidth: true
            from: 0.2
            to: 1.0
            stepSize: 0.05
        }

        Controls.Label {
            text: Math.round(backgroundOpacity.value * 100) + "%"
        }
    }

    Controls.CheckBox {
        id: glassEffect
        Kirigami.FormData.label: i18n("Glass:")
        text: i18n("Enable glass effect")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Intensity:")
        enabled: glassEffect.checked

        Controls.Slider {
            id: glassIntensity
            Layout.fillWidth: true
            from: 0.0
            to: 1.0
            stepSize: 0.05
        }

        Controls.Label {
            text: Math.round(glassIntensity.value * 100) + "%"
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Tone:")
        enabled: glassEffect.checked

        Controls.Slider {
            id: glassTone
            Layout.fillWidth: true
            from: -1.0
            to: 1.0
            stepSize: 0.05
        }

        Controls.Label {
            text: glassTone.value < -0.05 ? i18n("Darker") : (glassTone.value > 0.05 ? i18n("Lighter") : i18n("Neutral"))
        }
    }

    Controls.ComboBox {
        id: textContrast
        Kirigami.FormData.label: i18n("Text contrast:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: i18n("Automatic"), value: "auto" },
            { text: i18n("High"), value: "high" },
            { text: i18n("Soft"), value: "soft" }
        ]
    }
}
