#include "ImageExporter.h"

#include <QQuickItemGrabResult>
#include <QClipboard>
#include <QGuiApplication>
#include <QStandardPaths>
#include <QDir>
#include <QRegularExpression>
#include <QPainter>

ImageExporter::ImageExporter(QObject *parent) : QObject(parent) {}

// Composites src onto an opaque white canvas so transparent areas don't
// appear dark when the system is in dark mode.
static QImage onWhite(const QImage &src)
{
    QImage out(src.size(), QImage::Format_RGB32);
    out.fill(Qt::white);
    QPainter p(&out);
    p.drawImage(0, 0, src);
    return out;
}

void ImageExporter::grabAndCopy(QQuickItem *item)
{
    auto result = item->grabToImage();
    connect(result.data(), &QQuickItemGrabResult::ready, this, [this, result]() {
        QGuiApplication::clipboard()->setImage(onWhite(result->image()));
        emit copyDone();
    });
}

void ImageExporter::grabAndSave(QQuickItem *item, const QString &path)
{
    auto result = item->grabToImage();
    connect(result.data(), &QQuickItemGrabResult::ready, this, [this, result, path]() {
        onWhite(result->image()).save(path);
        emit saveDone(path);
    });
}

QString ImageExporter::defaultSavePath(const QString &place, const QString &date) const
{
    QString desktop = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    QString name    = place.isEmpty() ? "LunchBill" : place;
    name += "_" + date;
    name.replace(QRegularExpression(R"([/\\:*?"<>|])"), "_");
    return QDir(desktop).filePath(name + ".png");
}
