#pragma once

#include <QString>
#include <QList>

struct LunchItem {
    QString name;
    int     qty          = 1;
    double  price        = 0.0;     // unit price
    bool    scChargeable = true;    // subject to service charge?
    bool    taxable      = false;   // subject to SST?

    // One bool per person: did this person order this item?
    // Index matches LunchCalculator::m_persons
    QList<bool> personOrders;
};
