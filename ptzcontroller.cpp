#include "ptzcontroller.h"

PtzController::PtzController(QObject *parent)
    : QObject{parent}
{
}

void PtzController::sendCommand(const QString &command, float speed)
{
    // Пока что просто вывод консоль.
    // Здесь нужно написать логику отправки Protobuf-сообщения по MQTT

    qDebug() << "[C++] MQTT Отправка: команда =" << command << ", скорость =" << speed;
}