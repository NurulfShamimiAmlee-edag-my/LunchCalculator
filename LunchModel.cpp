#include "LunchModel.h"

// ── Static column indices ──────────────────────────────────────────────────
static constexpr int COL_NAME         = 0;
static constexpr int COL_PRICE        = 1;
static constexpr int COL_TAXABLE      = 2;
static constexpr int COL_SPLIT_COUNT  = 3;   // read-only, auto-calculated
static constexpr int COL_COST_PERSON  = 4;   // read-only, auto-calculated
static constexpr int FIXED_COLS       = 5;   // columns before person columns begin

LunchModel::LunchModel(QObject *parent)
    : QAbstractTableModel(parent)
{}

// ── Row / column counts ───────────────────────────────────────────────────

int LunchModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_items.size();
}

int LunchModel::columnCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return FIXED_COLS + m_persons.size();
}

// ── Data read ─────────────────────────────────────────────────────────────

QVariant LunchModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return {};
    if (index.row() < 0 || index.row() >= m_items.size()) return {};

    const LunchItem &item = m_items.at(index.row());
    const int col = index.column();

    if (role == Qt::DisplayRole || role == Qt::EditRole) {
        if (col == COL_NAME)    return item.name;
        if (col == COL_PRICE)   return item.price;
        if (col == COL_TAXABLE) return item.taxable;
        if (col == COL_SPLIT_COUNT) {
            return splitCountForRow(index.row());
        }
        if (col == COL_COST_PERSON) {
            int sc = splitCountForRow(index.row());
            return sc > 0 ? item.price / sc : 0.0;
        }
        if (isPersonColumn(col)) {
            int pi = personIndexFromColumn(col);
            if (pi < item.personOrders.size())
                return item.personOrders.at(pi);
            return false;
        }
    }
    return {};
}

// ── Data write ────────────────────────────────────────────────────────────

bool LunchModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || role != Qt::EditRole) return false;
    if (index.row() < 0 || index.row() >= m_items.size()) return false;

    LunchItem &item = m_items[index.row()];
    const int col   = index.column();

    if (col == COL_NAME) {
        item.name = value.toString();
    } else if (col == COL_PRICE) {
        item.price = value.toDouble();
    } else if (col == COL_TAXABLE) {
        item.taxable = value.toBool();
    } else if (col == COL_SPLIT_COUNT || col == COL_COST_PERSON) {
        return false;   // read-only, auto-calculated
    } else if (isPersonColumn(col)) {
        int pi = personIndexFromColumn(col);
        if (pi < item.personOrders.size())
            item.personOrders[pi] = value.toBool();
    } else {
        return false;
    }

    emit dataChanged(index, index, {Qt::DisplayRole, Qt::EditRole});

    // If a person checkbox changed, the split count and cost per person
    // columns are also affected — notify them so the view refreshes.
    if (isPersonColumn(col)) {
        QModelIndex splitIdx = createIndex(index.row(), COL_SPLIT_COUNT);
        QModelIndex costIdx  = createIndex(index.row(), COL_COST_PERSON);
        emit dataChanged(splitIdx, splitIdx, {Qt::DisplayRole});
        emit dataChanged(costIdx,  costIdx,  {Qt::DisplayRole});
    }

    emit dataModified();
    return true;
}

// ── Header data ───────────────────────────────────────────────────────────

QVariant LunchModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (role != Qt::DisplayRole) return {};
    if (orientation == Qt::Vertical) return section + 1;

    if (section == COL_NAME)         return "Item";
    if (section == COL_PRICE)        return "Price (MYR)";
    if (section == COL_TAXABLE)      return "Tax?";
    if (section == COL_SPLIT_COUNT)  return "Split Count";
    if (section == COL_COST_PERSON)  return "Cost per Person";
    if (isPersonColumn(section))
        return m_persons.at(personIndexFromColumn(section));

    return {};
}

// ── Flags ─────────────────────────────────────────────────────────────────

Qt::ItemFlags LunchModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) return Qt::NoItemFlags;
    int col = index.column();
    if (col == COL_SPLIT_COUNT || col == COL_COST_PERSON)
        return Qt::ItemIsEnabled | Qt::ItemIsSelectable;   // read-only
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

// ── Role names (for QML) ──────────────────────────────────────────────────

QHash<int, QByteArray> LunchModel::roleNames() const
{
    return {
            { Qt::DisplayRole, "display" },
            { Qt::EditRole,    "edit"    },
            };
}

// ── Person management ─────────────────────────────────────────────────────

void LunchModel::addPerson(const QString &name)
{
    const int newCol = FIXED_COLS + m_persons.size();
    beginInsertColumns({}, newCol, newCol);
    m_persons.append(name);
    // Extend every existing item's personOrders list
    for (LunchItem &item : m_items)
        item.personOrders.append(false);
    endInsertColumns();
    emit dataModified();
}

void LunchModel::removePerson(int personIndex)
{
    if (personIndex < 0 || personIndex >= m_persons.size()) return;
    const int col = FIXED_COLS + personIndex;
    beginRemoveColumns({}, col, col);
    m_persons.removeAt(personIndex);
    for (LunchItem &item : m_items)
        item.personOrders.removeAt(personIndex);
    endRemoveColumns();

    // Removing a person changes split counts and costs for any row they had checked.
    if (!m_items.isEmpty()) {
        emit dataChanged(createIndex(0, COL_SPLIT_COUNT),
                         createIndex(m_items.size() - 1, COL_COST_PERSON),
                         {Qt::DisplayRole});
    }

    emit dataModified();
}

void LunchModel::renamePerson(int personIndex, const QString &name)
{
    if (personIndex < 0 || personIndex >= m_persons.size()) return;
    m_persons[personIndex] = name;
    emit headerDataChanged(Qt::Horizontal,
                           FIXED_COLS + personIndex,
                           FIXED_COLS + personIndex);
}

// ── Item management ───────────────────────────────────────────────────────

void LunchModel::addItem()
{
    const int row = m_items.size();
    beginInsertRows({}, row, row);
    LunchItem item;
    item.personOrders.resize(m_persons.size());   // all false by default
    m_items.append(item);
    endInsertRows();
    emit dataModified();
}

void LunchModel::removeItem(int row)
{
    if (row < 0 || row >= m_items.size()) return;
    beginRemoveRows({}, row, row);
    m_items.removeAt(row);
    endRemoveRows();
    emit dataModified();
}

void LunchModel::clear()
{
    beginResetModel();
    m_items.clear();
    m_persons.clear();
    endResetModel();
    emit dataModified();
}

// ── Helpers ───────────────────────────────────────────────────────────────

bool LunchModel::isPersonColumn(int col) const
{
    return col >= FIXED_COLS && col < FIXED_COLS + m_persons.size();
}

int LunchModel::personIndexFromColumn(int col) const
{
    return col - FIXED_COLS;
}

int LunchModel::splitCountForRow(int row) const
{
    if (row < 0 || row >= m_items.size()) return 0;
    const LunchItem &item = m_items.at(row);
    int count = 0;
    for (bool ordered : item.personOrders)
        if (ordered) ++count;
    return count;
}
