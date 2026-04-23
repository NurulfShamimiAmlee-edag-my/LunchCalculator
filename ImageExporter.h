#pragma once

#include <QObject>
#include <QQuickItem>

class ImageExporter : public QObject
{
    Q_OBJECT

public:
    explicit ImageExporter(QObject *parent = nullptr);

    // Grab item and copy the resulting image to the system clipboard.
    Q_INVOKABLE void grabAndCopy(QQuickItem *item);

    // Grab item and save the resulting image to a PNG file at path.
    Q_INVOKABLE void grabAndSave(QQuickItem *item, const QString &path);

    // Returns a Desktop path like "LunchBill_PlaceName_4_23_2026.png".
    Q_INVOKABLE QString defaultSavePath(const QString &place, const QString &date) const;

signals:
    void copyDone();
    void saveDone(const QString &path);
};
