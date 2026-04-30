# Lunch Calculator

A desktop application for splitting lunch bills among colleagues. Handles Malaysian SST and service charge, tracks per-person totals, and compares against the actual receipt amount.

---

## Features

- Add unlimited bill items with quantity and unit price
- Independent **SC?** and **SST?** flags per item — an item can be subject to service charge only, SST only, both, or neither
- Select-all header checkboxes to tick an entire SC? or SST? column in one click
- Add/remove persons per session
- Automatic split calculation — items split equally among selected persons
- Service charge and SST applied independently based on per-item flags (no compounding)
- Per-person breakdown: food, SC+SST, and total
- Receipt amount entry with difference indicator (green = overpaid, red = underpaid)
- **Show/Hide Details** toggle to show or hide Split Count and Cost per Person columns
- Persistent names list managed in-app — no file editing required
- "New Bill" button to reset the session without restarting the app

---

## Requirements (Development)

| Tool | Version |
|---|---|
| Qt | 6.10.2 (MinGW 64-bit) |
| Qt Design Studio | 6.x |
| CMake | 3.21.1 or later |
| Compiler | MinGW 64-bit (bundled with Qt) |

---

## Building

1. Open **Qt Design Studio** (or Qt Creator)
2. Open `CMakeLists.txt` at the project root
3. Select the **Qt 6.10.2 MinGW 64-bit** kit
4. Click **Build → Build All**

To run the app directly from the IDE, press **Ctrl+R**.

---

## Project Structure

```
LunchCalculator/
├── CMakeLists.txt              # Root build configuration
├── LunchCalculator.h/cpp       # Main controller — calculations, totals, reset
├── LunchModel.h/cpp            # QAbstractTableModel — items and persons
├── LunchItem.h                 # Data struct for a single bill item
├── App/
│   ├── main.cpp                # Application entry point
│   └── CMakeLists.txt
└── LunchCalculatorContent/
    ├── App.qml                 # Main UI
    ├── PersonNames.qml         # Default names list (edit to change defaults)
    └── CMakeLists.txt
```

---

## How to Use

### Filling a Bill

1. Enter the **Place** and **Date** at the top
2. Set **Service Charge %** and **SST %** (yellow fields)
3. Add persons using **+ Add Person** — pick from the list or type a custom name
4. Click **+ Add Item** for each menu item:
   - Enter the item name
   - Set **Qty** (defaults to 1) and **Unit Price**
   - Tick **SC?** if the item is subject to service charge
   - Tick **SST?** if the item is subject to SST
   - Tick the checkboxes under each person's name who ordered that item
5. Enter the **Receipt Amt** from the actual bill — the **Difference** row shows any discrepancy

> **Tip:** To quickly mark all items in the SC? or SST? column, click the small checkbox in the column header.

### Quantity

When multiple people ordered the same item, enter the count in **Qty** instead of adding separate rows. For example, 3 people each ordering Kopi Ice at MYR 6.20 → Qty=3, Unit Price=6.20, tick all three persons. Each person's share works out to MYR 6.20.

Your existing workflow (Qty=1, enter total price) continues to work unchanged.

### SC? and SST? Flags

Each item independently controls whether service charge and SST apply:

| SC? | SST? | Effect |
|-----|------|--------|
| ✓ | ✓ | Both SC and SST applied (most common) |
| ✗ | ✓ | SST only — e.g. some beverages |
| ✓ | ✗ | SC only |
| ✗ | ✗ | Neither — e.g. vouchers, non-taxable items |

### Split Count and Cost per Person

These audit columns are hidden by default to keep the table compact. Click **Show Details** in the item toolbar to reveal them. Click **Hide Details** to collapse them again.

### Per-Person Totals

The blue bar at the bottom shows each person's food cost, combined SC+SST, and total amount to pay. It scrolls horizontally if there are more than a few persons.

### Starting a New Bill

Click **New Bill** (bottom-right of the item table) to clear all items, persons, and totals while keeping your settings.

---

## Managing the Names List

The names list is shared between the **+ Add Person** dialog and the **Pay To** dropdown. To manage it without editing any files:

1. Click the **⚙** button in the persons toolbar
2. Use the dialog to **add** or **remove** names
3. Click **Reset to defaults** to restore the original list from `PersonNames.qml`

Changes are saved automatically and persist between sessions.

To change the **default** list (what appears after a reset), edit `LunchCalculatorContent/PersonNames.qml`:

```qml
readonly property var names: [
    "Alice",
    "Bob",
    // add or remove names here
]
```

---

## Calculation Rules

| Field | Formula |
|---|---|
| Subtotal | Sum of (Qty × Unit Price) for all items |
| Service Charge | SC-flagged items total × SC% |
| SST | SST-flagged items total × SST% |
| Grand Total | Subtotal + Service Charge + SST |
| Per-person SC+SST | Proportional to each person's flagged food share |

SC and SST are calculated independently — an item's SC? and SST? flags are separate and do not compound.

---

## Deploying to Windows

Follow these steps to produce a standalone folder that colleagues can run without installing Qt.

### 1. Build in Release mode

In Qt Creator, switch the kit selector from **Debug** to **Release**, then run **Build → Rebuild All**.

### 2. Create a staging folder and copy the executable

```powershell
mkdir "$env:USERPROFILE\Desktop\LunchCalculator-dist"
copy "C:\Users\na87995\Documents\QtDesignStudio\LunchCalculatorApp-Release\LunchCalculatorApp.exe" "$env:USERPROFILE\Desktop\LunchCalculator-dist\"
```

### 3. Run `windeployqt`

```powershell
$exe = "$env:USERPROFILE\Desktop\LunchCalculator-dist\LunchCalculatorApp.exe"
$qml = "C:\Users\na87995\Documents\QtDesignStudio\LunchCalculator\LunchCalculatorContent"
& "C:\Qt\6.10.2\mingw_64\bin\windeployqt.exe" --qmldir $qml $exe
```

This copies all required Qt DLLs, plugins, and QML modules next to the executable.

### 4. Smoke test

Open `LunchCalculator-dist\` and double-click `LunchCalculatorApp.exe` to verify it launches correctly on a machine without Qt installed.

### 5. Zip and distribute

Right-click the `LunchCalculator-dist` folder → **Send to → Compressed (zipped) folder**.

Share the zip with colleagues — they unzip anywhere and double-click the `.exe`. No installation or additional software required.

> **Note:** The MinGW build does not require the Visual C++ Redistributable, so no extra setup is needed on target machines.
