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

// ── Reset ─────────────────────────────────────────────────────────────────

void LunchCalculator::reset()
{
    m_model->clear();

    m_place       = "";
    m_date        = QDate::currentDate().toString("M/d/yyyy");
    m_payTo       = "";
    m_receiptAmt  = 0.0;
    m_subtotal    = 0.0;
    m_serviceCharge = 0.0;
    m_sst         = 0.0;
    m_grandTotal  = 0.0;
    m_personTotals.clear();

    emit placeChanged();
    emit dateChanged();
    emit payToChanged();
    emit receiptAmtChanged();
    emit personsChanged();
    emit totalsChanged();
}

// ── Core calculation ──────────────────────────────────────────────────────
//
//  Split logic:
//  For each item, find how many persons ordered it.
//  Each person who ordered it pays: item.price / ordererCount
//  Negative prices (vouchers) are split among all persons who have the
//  voucher row ticked — same mechanism, works naturally.
//
//  SST is applied only to taxable items.
//  Service charge is applied only to taxable items.
//  SST base is taxable food only — service charge is NOT compounded into the SST base.
//  Per-person SC and SST are proportional to each person's taxable food share.

void LunchCalculator::recalculate()
{
    const QList<LunchItem> &items   = m_model->items();
    const QStringList      &persons = m_model->persons();
    const int               nPersons = persons.size();

    // Per-person food totals (before tax)
    QList<double> foodShare(nPersons, 0.0);
    // Per-person taxable food totals
    QList<double> taxableShare(nPersons, 0.0);

    double totalFood    = 0.0;
    double totalTaxable = 0.0;

    for (const LunchItem &item : items) {
        // Count how many persons ordered this item
        int orderers = 0;
        for (int p = 0; p < nPersons && p < item.personOrders.size(); ++p)
            if (item.personOrders.at(p)) ++orderers;

        if (orderers == 0) continue;   // nobody ordered it — skip

        const double share = item.price / orderers;

        for (int p = 0; p < nPersons && p < item.personOrders.size(); ++p) {
            if (item.personOrders.at(p)) {
                foodShare[p] += share;
                if (item.taxable)
                    taxableShare[p] += share;
            }
        }

        totalFood    += item.price;
        if (item.taxable)
            totalTaxable += item.price;
    }

    // Bill-level totals
    m_subtotal      = totalFood;                                          // all food
    m_serviceCharge = totalTaxable * (m_serviceChargePct / 100.0);       // taxable food only
    m_sst           = totalTaxable * (m_sstPct           / 100.0);       // taxable food only, no SC compounding
    m_grandTotal    = m_subtotal + m_serviceCharge + m_sst;

    // Per-person totals — both SC and SST scale with taxable food share.
    m_personTotals.clear();
    for (int p = 0; p < nPersons; ++p) {
        double personServiceCharge = (totalTaxable > 0.0)
            ? taxableShare[p] / totalTaxable * m_serviceCharge : 0.0;
        double personSst = (totalTaxable > 0.0)
            ? taxableShare[p] / totalTaxable * m_sst : 0.0;
        double personTotal = foodShare[p] + personServiceCharge + personSst;

        QVariantMap entry;
        entry["name"]          = persons.at(p);
        entry["food"]          = qRound(foodShare[p]    * 100.0) / 100.0;
        entry["taxableFood"]   = qRound(taxableShare[p] * 100.0) / 100.0;
        entry["tax"]           = qRound(personSst       * 100.0) / 100.0;
        entry["serviceCharge"] = qRound(personServiceCharge * 100.0) / 100.0;
        entry["total"]         = qRound(personTotal     * 100.0) / 100.0;
        m_personTotals.append(entry);
    }

    emit totalsChanged();
}
