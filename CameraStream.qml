import QtQuick
import QtQuick.Controls

// Если выбираем RTSP, то нужно раскомментировать эту строку:
// import QtMultimedia

// Если выбираем WebRTC, то нужно раскомментировать эту строку
// import QtWebView

Rectangle {
    id: root
    color: "black"

    // Сюда должны передаваться ссылки на видео
    property string streamUrl: ""
    property string cameraName: "Камера"

    // Пока нет реального видео, показываем заглушку
    Label {
        anchors.centerIn: parent
        text: "🎥 " + root.cameraName + "\nЗагрузка видео..."
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        visible: streamUrl === "" // Прячем текст, если ссылка получена
    }

    // --- Место для будущего кода ---

    // ВАРИАНТ А: RTSP (Через Qt Multimedia)
    /*
    MediaPlayer {
        id: player
        source: root.streamUrl
        videoOutput: videoOut
        autoPlay: true
    }
    VideoOutput {
        id: videoOut
        anchors.fill: parent
    }
    */

    // ВАРИАНТ Б: WebRTC (Через WebView)
    /*
    WebView {
        anchors.fill: parent
        url: root.streamUrl
    }
    */
}