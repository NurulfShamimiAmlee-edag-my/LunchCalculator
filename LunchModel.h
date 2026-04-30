#pragma once

#include <QAbstractTableModel>
#include <QList>
#include "LunchItem.h"

// ---------------------------------------------------------------------------
//  Column layout
//  Col 0        : Item name          (QString, editable)
//  Col 1        : Qty                (int,     editable)
//  Col 2        : Unit Price         (double,  editable)
//  Col 3        : SC?                (bool,    editable)   — service charge
//  Col 4        : SST?               (bool,    editable)   — sales & service tax
//  Col 5        : Split Count        (int,     read-only, auto-calculated)
//  Col 6        : Cost per Person    (double,  read-only, auto-calculated)
//  Col 7 .. N+6 : Person[0..N-1]    (bool,    editable)
// ---------------------------------------------------------------------------

class LunchModel : public QAbstractTableModel
{
    Q_OBJECT

public:
    // Custom roles exposed to QML
    enum Roles {
        NameRole    = Qt::UserRole + 1,
        PriceRole,
        TaxableRole,
        PersonOrderRole   // carries column index via Qt::UserRole data trick — see data()
    };

    explicit LunchModel(QObject *parent = nullptr);

    // ── QAbstractTableModel interface ──────────────────────────────────────
    int rowCount   (const QModelIndex &parent = {}) const override;
    int columnCount(const QModelIndex &parent = {}) const override;

    QVariant data     (const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool     setData  (const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const override;

    // ── Person management (called from LunchCalculator) ───────────────────
    void addPerson   (const QString &name);
    void removePerson(int personIndex);
    void renamePerson(int personIndex, const QString &name);

    // ── Item management ───────────────────────────────────────────────────
    Q_INVOKABLE void addItem   ();
    Q_INVOKABLE void removeItem(int row);
    Q_INVOKABLE void setAllSC (bool v);
    Q_INVOKABLE void setAllSST(bool v);
    void clear();

    // ── Read-only accessors used by LunchCalculator for totals ────────────
    const QList<LunchItem> &items()   const { return m_items;   }
    const QStringList      &persons() const { return m_persons; }

signals:
    void dataModified();   // emitted whenever any cell changes → triggers recalculation

private:
    QList<LunchItem> m_items;
    QStringList      m_persons;

    bool isPersonColumn(int col) const;
    int  personIndexFromColumn(int col) const;
    int  splitCountForRow(int row) const;       // counts ticked persons for that item
};
