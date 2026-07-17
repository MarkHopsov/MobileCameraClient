import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import MobileCameraClient

ApplicationWindow {
    id: window
    width: 360  // Примерная ширина телефона
    height: 640 // Примерная высота телефона
    visible: true
    title: qsTr("Mobile Camera Client")
    Material.theme: Material.Dark
    Material.accent: Material.Blue

    PtzController {
        id: ptzController
    }

    // --- Шапка ---
    header: ToolBar {
        RowLayout {
            anchors.fill: parent

            // Умная кнопка (либо "гамбургер", либо кнопка "Назад")
            ToolButton {
                // Если мы глубже 1-го экрана, показываем стрелку, иначе Гамбургер
                icon.source: stackView.depth > 1 ? "icons/back.svg" : "icons/menu.svg"
                font.pixelSize: 24
                onClicked: {
                    if (stackView.depth > 1) {
                        stackView.pop() // Возвращаемся на сетку камер
                    } else {
                        drawer.open()   // Открываем меню
                    }
                }
            }

            // Заголовок текущего экрана
            Label {
                id: topTitle
                text: "Выберите сервер"
                font.pixelSize: 18
                elide: Label.ElideRight // Обрезает длинный текст троеточием
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            // Пустой элемент для балансировки (чтобы заголовок был по центру)
            Item {
                Layout.preferredWidth: 40
            }
        }
    }

    // --- Дерево серверов ---
        Drawer {
            id: drawer
            width: window.width * 0.75 // Занимает 75% ширины экрана
            height: window.height

            // Фейковая база данных, которую нужно заменить на C++
            ListModel { // От балды тут всякое написано
                id: serverModel
                ListElement { nodeName: "Главный Офис"; serverName: "Сервер 1-го этажа" }
                ListElement { nodeName: "Главный Офис"; serverName: "Сервер Парковки" }
                ListElement { nodeName: "Склад"; serverName: "Сервер ангара А" }
                ListElement { nodeName: "Улица"; serverName: "Периметр" }
            }

            // Сам список, который отображает данные
            ListView {
                id: serverList
                anchors.fill: parent
                model: serverModel

                // Настройка группировки для узлов
                section.property: "nodeName"
                section.delegate: Item {
                    width: ListView.view.width
                    height: 40

                    // Фон для заголовка Узла
                    Rectangle {
                        anchors.fill: parent
                        color: Material.color(Material.BlueGrey)
                    }

                    // Текст заголовка Узла
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        text: section // Сюда подставится "Главный Офис" и т.д.
                        font.bold: true
                        font.pixelSize: 14
                        color: "white"
                    }
                }

                // Настройка отображения серверов (кликабельные элементы)
                delegate: ItemDelegate {
                    width: ListView.view.width
                    text: "🖥️ " + serverName // Иконка и название сервера

                    onClicked: {
                        topTitle.text = serverName
                        drawer.close()

                        // Очищаем старые камеры
                        cameraModel.clear()

                        // Добавляем новые камеры в зависимости от того, какой сервер выбрали
                        // (в будущем здесь должен быть приём данных по MQTT)
                        cameraModel.append({ camName: "Камера 1 (Вход)" })
                        cameraModel.append({ camName: "Камера 2 (Холл)" })
                        cameraModel.append({ camName: "Камера 3" })

                        // Просто для красоты и разнообразия: если нажали на первый сервер, добавим больше камер
                        if (serverName === "Сервер 1-го этажа") {
                            cameraModel.append({ camName: "Камера 4 (Лестница)" })
                            cameraModel.append({ camName: "Камера 5" })
                        }
                    }
                }
            }
        }

    // Фейковая база данных для камер (изначально пустая)
        ListModel {
            id: cameraModel
        }

    // --- Переключатель экранов ---
        StackView {
            id: stackView
            anchors.fill: parent

            // Начальный экран (Сетка камер)
            initialItem: Page {

                // Сама сетка
                GridView {
                    id: cameraGrid
                    anchors.fill: parent
                    anchors.margins: 10

                    // Настройки ячеек (по 2 в ряд)
                    cellWidth: width / 2
                    cellHeight: cellWidth * 0.85

                    clip: true // ВАЖНО: чтобы при скролле карточки не вылезали за пределы сетки
                    model: cameraModel

                    // Шаблон одной карточки с камерой
                    delegate: Item {
                        width: cameraGrid.cellWidth
                        height: cameraGrid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5 // Отступы между карточками
                            color: Material.color(Material.BlueGrey, Material.Shade800) // Темно-серо-синий фон
                            radius: 8 // Закругленные углы

                            // Видео
                            CameraStream {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: parent.height * 0.75
                                cameraName: camName
                                // streamUrl: "тут_будет_ссылка_на_low_quality"
                            }
                            // Просто старая заглушка
                            // Rectangle {
                            //     anchors.top: parent.top
                            //     anchors.left: parent.left
                            //     anchors.right: parent.right
                            //     height: parent.height * 0.75 // Видео занимает 75% высоты карточки
                            //     color: "black"
                            //     radius: 8

                            //     Label {
                            //         anchors.centerIn: parent
                            //         text: "🎥\nНет сигнала"
                            //         horizontalAlignment: Text.AlignHCenter
                            //         color: "gray"
                            //     }
                            // }

                            // Название камеры внизу карточки
                            Label {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 8
                                text: camName // Берётся из модели данных
                                font.pixelSize: 14
                                elide: Text.ElideRight // Если название длинное - обрежет троеточием
                                horizontalAlignment: Text.AlignHCenter
                            }

                            // Кнопка поверх всей карточки (для перехода к управлению)
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    // push берет шаблон ptzComponent и передает ему переменную camName
                                    stackView.push(ptzComponent, { "currentCameraName": camName })
                                }
                            }
                        }
                    }
                }

                // Надпись, которая показывается, если камер нет
                Label {
                    anchors.centerIn: parent
                    text: "Выберите сервер в меню"
                    visible: cameraModel.count === 0 // Видима только если модель пустая
                    color: Material.color(Material.Grey)
                    font.pixelSize: 16
                }
            }
        }

    // --- Шаблон экрана управления камерой ---
        Component {
            id: ptzComponent

            Page {
                property string currentCameraName: "Неизвестная камера"

                // 1. Видеоплеер (Фон на весь экран)
                CameraStream {
                    id: videoPlayerArea
                    anchors.fill: parent
                    cameraName: currentCameraName
                    // streamUrl: "тут_будет_ссылка_на_high_quality"

                    // Зона для кликов
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (controlsOverlay.opacity === 0.0) {
                                controlsOverlay.opacity = 1.0
                                uiHideTimer.restart()
                            } else {
                                controlsOverlay.opacity = 0.0
                            }
                        }
                    }
                }
                // Просто старая заглушка
                // Rectangle {
                //     id: videoPlayerArea
                //     anchors.fill: parent
                //     color: "black"

                //     Label {
                //         anchors.centerIn: parent
                //         text: "🎥 " + currentCameraName
                //         color: "white"
                //         horizontalAlignment: Text.AlignHCenter
                //     }

                //     // Эта зона ловит клики по видео, чтобы показать/скрыть интерфейс
                //     MouseArea {
                //         anchors.fill: parent
                //         onClicked: {
                //             if (controlsOverlay.opacity === 0.0) {
                //                 controlsOverlay.opacity = 1.0
                //                 uiHideTimer.restart()
                //             } else {
                //                 controlsOverlay.opacity = 0.0
                //             }
                //         }
                //     }
                // }

                // Таймер авто-скрытия интерфейса
                Timer {
                    id: uiHideTimer
                    interval: 4000
                    running: true
                    onTriggered: controlsOverlay.opacity = 0.0
                }

                // 2. Слой интерфейса управления (поверх видео)
                Item {
                    id: controlsOverlay
                    anchors.fill: parent
                    opacity: 1.0

                    Behavior on opacity { NumberAnimation { duration: 300 } }

                    // --- Джойстик ---
                    GridLayout {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.margins: 15
                        columns: 3
                        rows: 3
                        columnSpacing: 8
                        rowSpacing: 8

                        component PtzButton: Button {
                            property string commandName: ""
                            property string iconName: ""

                            implicitWidth: 55
                            implicitHeight: 55
                            opacity: 0.8

                            icon.source: "icons/" + iconName
                            icon.width: 32
                            icon.height: 32

                            onPressed: {
                                uiHideTimer.stop()
                                ptzController.sendCommand(commandName, speedSlider.value)
                            }
                            onReleased: {
                                uiHideTimer.restart()
                                ptzController.sendCommand("stop", speedSlider.value)
                            }
                        }

                        Item { width: 55; height: 55 }
                        PtzButton { iconName: "up.svg"; commandName: "up" }
                        Item { width: 55; height: 55 }

                        PtzButton { iconName: "left.svg"; commandName: "left" }
                        Item { width: 55; height: 55 }
                        PtzButton { iconName: "right.svg"; commandName: "right" }

                        Item { width: 55; height: 55 }
                        PtzButton { iconName: "down.svg"; commandName: "down" }
                        Item { width: 55; height: 55 }
                    }

                    // --- Правая панель (скорость и зум) ---
                    ColumnLayout {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: 15
                        spacing: 10

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Скор: " + speedSlider.value.toFixed(1)
                            color: "white"
                            font.bold: true
                            style: Text.Outline; styleColor: "black"
                        }

                        Slider {
                            id: speedSlider
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredHeight: 120
                            orientation: Qt.Vertical
                            from: 0.0
                            to: 1.0
                            value: 0.5
                            stepSize: 0.1

                            onPressedChanged: {
                                if (pressed) uiHideTimer.stop()
                                else uiHideTimer.restart()
                            }
                        }

                        Button {
                            icon.source: "icons/zoom_in.svg"
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 50
                            opacity: 0.8

                            onPressed: {
                                uiHideTimer.stop();
                                ptzController.sendCommand("zoom_in", speedSlider.value)
                            }
                            onReleased: {
                                uiHideTimer.restart();
                                ptzController.sendCommand("stop", speedSlider.value)
                            }
                        }

                        Button {
                            icon.source: "icons/zoom_out.svg"
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 50
                            opacity: 0.8

                            onPressed: {
                                uiHideTimer.stop();
                                ptzController.sendCommand("zoom_out", speedSlider.value)
                            }
                            onReleased: {
                                uiHideTimer.restart();
                                ptzController.sendCommand("stop", speedSlider.value)
                            }
                        }
                    }
                }
            }
        }
}