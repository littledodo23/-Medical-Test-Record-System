# 🩺 Medical Test Record System

A simple and interactive **Bash-based medical test record manager**. This script allows users to manage patient medical test records, including adding, updating, deleting, searching, and analyzing test data.

---

## 📁 File

- `midecalRecord.sh`: The main script file for managing medical test records.

---

## 📋 Features

- ✅ Add a new medical test record
- 🔍 Search tests by:
  - Patient ID
  - Test status
  - Date range
  - Abnormality detection
- 🧮 Calculate average test results (for individual patients or overall)
- 🛠️ Update existing records
- ❌ Delete records
- ⚠️ Automatically flags abnormal test results based on medical norms

---

## 🧪 Test Types Supported

- **Hgb (Hemoglobin)** – Normal range: `13.8 - 17.2 g/dL`
- **BGT (Blood Glucose Test)** – Normal range: `70 - 99 mg/dL`
- **LDL (Cholesterol)** – Normal range: `< 100 mg/dL`
- **Systole** – Normal range: `< 120 mm Hg`
- **Diastole** – Normal range: `< 80 mm Hg`

---

## ▶️ How to Run

1. Make the script executable:

   ```bash
   chmod +x midecalRecord.sh
