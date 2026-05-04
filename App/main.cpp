#include <QGuiApplication>
#include <QStyleHints>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "LunchCalculator.h"
#include "ImageExporter.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.styleHints()->setColorScheme(Qt::ColorScheme::Light);  // always light — ignore system dark mode
    app.setOrganizationName("LunchCalc");
    app.setApplicationName("Lunch Calculator");

    // Register types so QML can use LunchModel in TableView
    qmlRegisterUncreatableType<LunchModel>(
        "LunchCalc", 1, 0, "LunchModel",
        "LunchModel is created by LunchCalculator");

    QQmlApplicationEngine engine;

    // Create the single controller instance and expose it to QML
    LunchCalculator calculator;
    engine.rootContext()->setContextProperty("calculator", &calculator);

    ImageExporter imageExporter;
    engine.rootContext()->setContextProperty("imageExporter", &imageExporter);

    // Seed some demo data so the UI isn't blank on first launch
    calculator.setPlace("Tealive");
    calculator.addPerson("Mimi");
    calculator.addPerson("Syahnaz");
    calculator.addPerson("Chobnaa");
    calculator.addItem();   // users will fill these in
    calculator.addItem();

    const QUrl url(
#ifdef Q_OS_ANDROID
        u"qrc:/qt/qml/LunchCalculatorContent/AppAndroid.qml"_qs
#else
        u"qrc:/qt/qml/LunchCalculatorContent/App.qml"_qs
#endif
    );
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app,    &QGuiApplication::quit,
        Qt::QueuedConnection);

    engine.load(url);
    return app.exec();
}
