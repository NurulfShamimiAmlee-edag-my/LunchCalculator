#pragma once

#include <QString>
#include <QList>

struct LunchItem {
    QString name;
    double  price       = 0.0;
    bool    taxable     = false;    // subject to SST?

    // One bool per person: did this person order this item?
    // Index matches LunchCalculator::m_persons
    QList<bool> personOrders;
};
