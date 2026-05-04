#include "LunchCalculator.h"
#include <QDate>
#include <QVariantMap>
#include <cmath>

LunchCalculator::LunchCalculator(QObject *parent)
    : QObject(parent)
    , m_model(new LunchModel(this))
    , m_date(QDate::currentDate().toString("M/d/yyyy"))
{
    connect(m_model, &LunchModel::dataModified, this, &LunchCalculator::recalculate);
}

// ── Property setters ──────────────────────────────────────────────────────

void LunchCalculator::setPlace(const QString &v)
{
    if (m_place == v) return;
    m_place = v;
    emit placeChanged();
}

void LunchCalculator::setDate(const QString &v)
{
    if (m_date == v) return;
    m_date = v;
    emit dateChanged();
}

void LunchCalculator::setPayTo(const QString &v)
{
    if (m_payTo == v) return;
    m_payTo = v;
    emit payToChanged();
}

void LunchCalculator::setServiceChargePct(double v)
{
    if (qFuzzyCompare(m_serviceChargePct, v)) return;
    m_serviceChargePct = v;
    emit serviceChargePctChanged();
    recalculate();
}

void LunchCalculator::setSstPct(double v)
{
    if (qFuzzyCompare(m_sstPct, v)) return;
    m_sstPct = v;
    emit sstPctChanged();
    recalculate();
}

void LunchCalculator::setReceiptAmt(double v)
{
    if (qFuzzyCompare(m_receiptAmt, v)) return;
    m_receiptAmt = v;
    emit receiptAmtChanged();
    emit totalsChanged();   // difference depends on receiptAmt
}

// ── Person management ─────────────────────────────────────────────────────

void LunchCalculator::addPerson(const QString &name)
{
    m_model->addPerson(name);
    emit personsChanged();
    recalculate();
}

void LunchCalculator::removePerson(int index)
{
    m_model->removePerson(index);
    emit personsChanged();
    recalculate();
}

void LunchCalculator::renamePerson(int index, const QString &name)
{
    m_model->renamePerson(index, name);
    emit personsChanged();
}

// ── Item data access (for Android QML) ───────────────────────────────────

QVariantList LunchCalculator::itemsData() const
{
    QVariantList result;
    for (const LunchItem &item : m_model->items()) {
        QVariantList orders;
        for (bool b : item.personOrders) orders << b;
        result << QVariantMap{
            {"name",         item.name},
            {"qty",          item.qty},
            {"price",        item.price},
            {"sc",           item.scChargeable},
            {"taxable",      item.taxable},
            {"personOrders", orders}
        };
    }
    return result;
}

void LunchCalculator::updateItem(int row, const QString &name, int qty, double price,
                                 bool sc, bool taxable, const QVariantList &personOrders)
{
    auto *m = m_model;
    m->setData(m->index(row, 0), name,    Qt::EditRole);
    m->setData(m->index(row, 1), qty,     Qt::EditRole);
    m->setData(m->index(row, 2), price,   Qt::EditRole);
    m->setData(m->index(row, 3), sc,      Qt::EditRole);
    m->setData(m->index(row, 4), taxable, Qt::EditRole);
    const int personCount = m_model->persons().size();
    for (int i = 0; i < personOrders.size() && i < personCount; ++i)
        m->setData(m->index(row, 7 + i), personOrders[i].toBool(), Qt::EditRole);
}

// ── Reset ─────────────────────────────────────────────────────────────────

void LunchCalculator::reset()
{
    m_model->clear();

    m_place         = "";
    m_date          = QDate::currentDate().toString("M/d/yyyy");
    m_payTo         = "";
    m_receiptAmt    = 0.0;
    m_subtotal      = 0.0;
    m_serviceCharge = 0.0;
    m_sst           = 0.0;
    m_grandTotal    = 0.0;
    m_allSC         = false;
    m_allSST        = false;
    m_personTotals.clear();

    emit placeChanged();
    emit dateChanged();
    emit payToChanged();
    emit receiptAmtChanged();
    emit personsChanged();
    emit totalsChanged();
}

// ── Core calculation ──────────────────────────────────────────────────────

void LunchCalculator::recalculate()
{
    const QList<LunchItem> &items   = m_model->items();
    const QStringList      &persons = m_model->persons();
    const int               nPersons = persons.size();

    QList<double> foodShare(nPersons, 0.0);
    QList<double> scShare  (nPersons, 0.0);
    QList<double> sstShare (nPersons, 0.0);

    double totalFood    = 0.0;
    double totalSCBase  = 0.0;
    double totalSSTBase = 0.0;

    for (const LunchItem &item : items) {
        int orderers = 0;
        for (int p = 0; p < nPersons && p < item.personOrders.size(); ++p)
            if (item.personOrders.at(p)) ++orderers;

        if (orderers == 0) continue;

        const double effectivePrice = item.qty * item.price;
        const double share = effectivePrice / orderers;

        for (int p = 0; p < nPersons && p < item.personOrders.size(); ++p) {
            if (item.personOrders.at(p)) {
                foodShare[p] += share;
                if (item.scChargeable) scShare [p] += share;
                if (item.taxable)      sstShare[p] += share;
            }
        }

        totalFood += effectivePrice;
        if (item.scChargeable) totalSCBase  += effectivePrice;
        if (item.taxable)      totalSSTBase += effectivePrice;
    }

    m_subtotal      = totalFood;
    m_serviceCharge = totalSCBase  * (m_serviceChargePct / 100.0);
    m_sst           = totalSSTBase * (m_sstPct           / 100.0);
    m_grandTotal    = m_subtotal + m_serviceCharge + m_sst;

    bool allSC = !items.isEmpty(), allSST = !items.isEmpty();
    for (const LunchItem &item : items) {
        if (!item.scChargeable) allSC  = false;
        if (!item.taxable)      allSST = false;
    }
    m_allSC  = allSC;
    m_allSST = allSST;

    m_personTotals.clear();
    for (int p = 0; p < nPersons; ++p) {
        double personSC  = (totalSCBase  > 0.0) ? scShare [p] / totalSCBase  * m_serviceCharge : 0.0;
        double personSST = (totalSSTBase > 0.0) ? sstShare[p] / totalSSTBase * m_sst           : 0.0;
        double personTotal = foodShare[p] + personSC + personSST;

        QVariantMap entry;
        entry["name"]          = persons.at(p);
        entry["food"]          = qRound(foodShare[p] * 100.0) / 100.0;
        entry["taxableFood"]   = qRound(sstShare [p] * 100.0) / 100.0;
        entry["tax"]           = qRound(personSST    * 100.0) / 100.0;
        entry["serviceCharge"] = qRound(personSC     * 100.0) / 100.0;
        entry["total"]         = qRound(personTotal  * 100.0) / 100.0;
        m_personTotals.append(entry);
    }

    emit totalsChanged();
}
