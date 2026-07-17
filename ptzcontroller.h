#ifndef PTZCONTROLLER_H
#define PTZCONTROLLER_H

#include <QObject>
#include <QtQml>
#include <QDebug>

class PtzController : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit PtzController(QObject *parent = nullptr);

    Q_INVOKABLE void sendCommand(const QString &command, float speed);
};

#endif // PTZCONTROLLER_H