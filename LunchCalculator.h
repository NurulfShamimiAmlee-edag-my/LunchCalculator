#pragma once

#include <QObject>
#include <QList>
#include <QString>
#include <qqmlintegration.h>
#include "LunchModel.h"

// ---------------------------------------------------------------------------
//  LunchCalculator
//
//  Acts as the single QML-facing controller.
//  Owns the LunchModel and exposes:
//    • the model itself (for TableView)
//    • session settings  (place, date, serviceCharge%, sst%)
//    • person management (add / remove / rename)
//    • calculated per-person totals + grand total
// ---------------------------------------------------------------------------

class LunchCalculator : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    // ── Session metadata ──────────────────────────────────────────────────
    Q_PROPERTY(QString  place          READ place          WRITE setPlace          NOTIFY placeChanged)
    Q_PROPERTY(QString  date           READ date           WRITE setDate           NOTIFY dateChanged)
    Q_PROPERTY(QString  payTo          READ payTo          WRITE setPayTo          NOTIFY payToChanged)

    // ── Tax / service settings ────────────────────────────────────────────
    Q_PROPERTY(double   serviceChargePct READ serviceChargePct WRITE setServiceChargePct NOTIFY serviceChargePctChanged)
    Q_PROPERTY(double   sstPct          READ sstPct          WRITE setSstPct          NOTIFY sstPctChanged)
    Q_PROPERTY(bool     allSC           READ allSC           NOTIFY totalsChanged)
    Q_PROPERTY(bool     allSST          READ allSST          NOTIFY totalsChanged)

    // ── Model ─────────────────────────────────────────────────────────────
    Q_PROPERTY(LunchModel* model        READ model          CONSTANT)

    // ── Computed totals ───────────────────────────────────────────────────
    Q_PROPERTY(double   subtotal        READ subtotal        NOTIFY totalsChanged)
    Q_PROPERTY(double   serviceCharge   READ serviceCharge   NOTIFY totalsChanged)
    Q_PROPERTY(double   sst             READ sst             NOTIFY totalsChanged)
    Q_PROPERTY(double   grandTotal      READ grandTotal      NOTIFY totalsChanged)
    Q_PROPERTY(double   receiptAmt      READ receiptAmt      WRITE setReceiptAmt  NOTIFY receiptAmtChanged)
    Q_PROPERTY(double   difference      READ difference      NOTIFY totalsChanged)

    // ── Per-person totals (serialised as QVariantList for QML) ────────────
    Q_PROPERTY(QVariantList personTotals READ personTotals  NOTIFY totalsChanged)

    // ── Person list (names only, for column headers / person management) ──
    Q_PROPERTY(QStringList persons      READ persons         NOTIFY personsChanged)

public:
    explicit LunchCalculator(QObject *parent = nullptr);

    // ── Property getters ──────────────────────────────────────────────────
    QString     place()            const { return m_place; }
    QString     date()             const { return m_date;  }
    QString     payTo()            const { return m_payTo; }
    double      serviceChargePct() const { return m_serviceChargePct; }
    double      sstPct()           const { return m_sstPct; }
    bool        allSC()            const { return m_allSC;  }
    bool        allSST()           const { return m_allSST; }
    LunchModel *model()            const { return m_model; }

    double subtotal()      const { return m_subtotal;      }
    double serviceCharge() const { return m_serviceCharge; }
    double sst()           const { return m_sst;           }
    double grandTotal()    const { return m_grandTotal;    }
    double receiptAmt()    const { return m_receiptAmt;    }
    double difference()    const { return m_receiptAmt - m_grandTotal; }

    QVariantList personTotals() const { return m_personTotals; }
    QStringList  persons()      const { return m_model->persons(); }

    // ── Property setters ──────────────────────────────────────────────────
    void setPlace         (const QString &v);
    void setDate          (const QString &v);
    void setPayTo         (const QString &v);
    void setServiceChargePct(double v);
    void setSstPct        (double v);
    void setReceiptAmt    (double v);

    // ── QML-invokable person management ───────────────────────────────────
    Q_INVOKABLE void addPerson   (const QString &name);
    Q_INVOKABLE void removePerson(int index);
    Q_INVOKABLE void renamePerson(int index, const QString &name);

    // ── Convenience pass-through for item management ───────────────────────
    Q_INVOKABLE void addItem   ()         { m_model->addItem();    }
    Q_INVOKABLE void removeItem(int row)  { m_model->removeItem(row); }
    Q_INVOKABLE void reset();

signals:
    void placeChanged();
    void dateChanged();
    void payToChanged();
    void serviceChargePctChanged();
    void sstPctChanged();
    void totalsChanged();
    void personsChanged();
    void receiptAmtChanged();

private slots:
    void recalculate();

private:
    LunchModel  *m_model;

    // session metadata
    QString m_place;
    QString m_date;
    QString m_payTo;

    // tax settings
    double m_serviceChargePct = 0.0;
    double m_sstPct           = 6.0;

    // computed totals
    double       m_subtotal      = 0.0;
    double       m_serviceCharge = 0.0;
    double       m_sst           = 0.0;
    double       m_grandTotal    = 0.0;
    double       m_receiptAmt    = 0.0;
    bool         m_allSC         = false;
    bool         m_allSST        = false;
    QVariantList m_personTotals;
};
