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

void LunchCalculator::setDiscountMode(int v)
{
    if (m_discountMode == v) return;
    m_discountMode = v;
    emit discountModeChanged();
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

    m_place         = "";
    m_date          = QDate::currentDate().toString("M/d/yyyy");
    m_payTo         = "";
    m_receiptAmt    = 0.0;
    m_subtotal      = 0.0;
    m_serviceCharge = 0.0;
    m_sst           = 0.0;
    m_grandTotal    = 0.0;
    m_discountMode  = 0;
    m_personTotals.clear();

    emit placeChanged();
    emit dateChanged();
    emit payToChanged();
    emit receiptAmtChanged();
    emit personsChanged();
    emit discountModeChanged();
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
//  discountMode == 0  (Unified):
//    SC and SST share the same taxable base — current default behaviour.
//    Taxable discount items reduce both bases equally.
//
//  discountMode == 1  (SST Only):
//    SC base  = positive taxable items only  (pre-discount)
//    SST base = all taxable items            (post-discount)
//    This replicates the common Malaysian restaurant pattern where the
//    restaurant's discount reduces SST but not service charge.

void LunchCalculator::recalculate()
{
    const QList<LunchItem> &items   = m_model->items();
    const QStringList      &persons = m_model->persons();
    const int               nPersons = persons.size();

    QList<double> foodShare(nPersons, 0.0);
    QList<double> scShare  (nPersons, 0.0);   // per-person SC taxable share
    QList<double> sstShare (nPersons, 0.0);   // per-person SST taxable share

    double totalFood    = 0.0;
    double totalSCBase  = 0.0;
    double totalSSTBase = 0.0;

    for (const LunchItem &item : items) {
        int orderers = 0;
        for (int p = 0; p < nPersons && p < item.personOrders.size(); ++p)
            if (item.personOrders.at(p)) ++orderers;

        if (orderers == 0) continue;

        const double share = item.price / orderers;
        const bool inSCBase = item.taxable &&
                              (m_discountMode == 0 || item.price >= 0.0);

        for (int p = 0; p < nPersons && p < item.personOrders.size(); ++p) {
            if (item.personOrders.at(p)) {
                foodShare[p] += share;
                if (inSCBase)    scShare [p] += share;
                if (item.taxable) sstShare[p] += share;
            }
        }

        totalFood += item.price;
        if (inSCBase)     totalSCBase  += item.price;
        if (item.taxable) totalSSTBase += item.price;
    }

    m_subtotal      = totalFood;
    m_serviceCharge = totalSCBase  * (m_serviceChargePct / 100.0);
    m_sst           = totalSSTBase * (m_sstPct           / 100.0);
    m_grandTotal    = m_subtotal + m_serviceCharge + m_sst;

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
