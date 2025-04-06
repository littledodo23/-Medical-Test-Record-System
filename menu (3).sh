# Define the file where all medical test records will be stored
FILE="midecalRecord.sh"

# Define normal ranges for different tests using an associative array
declare -A normal_ranges=(
    ["Hgb"]="13.8-17.2"
    ["BGT"]="70-99"
    ["LDL"]="<100"
    ["systole"]="<120"
    ["diastole"]="<80"
)

# Function to display the main menu
display_menu() {
    clear
    echo "==============================="
    echo "        Medical Test System"
    echo "==============================="
    echo "1. Add a new medical test record"
    echo "2. Search for a test by patient ID"
    echo "   a. Retrieve all patient tests"
    echo "   b. Retrieve all abnormal patient tests"
    echo "   c. Retrieve all patient tests in a given specific period"
    echo "   d. Retrieve all patient tests based on test status"
    echo "   e. Retrieve all abnormal tests"
    echo "3. Average test value"
    echo "4. Delete an existing test result"
    echo "5. Update an existing test result"
    echo "6. Calculate average test values"
    echo "7. Exit"
    echo "==============================="
    echo -n "Please choose an option: "
}

# Function to add a new medical test record
add_record() {
    echo "Enter Patient ID (7-digit integer):"
    read -r patient_id
    # Validate that the patient ID is a 7-digit integer
    if ! [[ $patient_id =~ ^[0-9]{7}$ ]]; then
        echo "Invalid Patient ID. Must be a 7-digit integer."
        return
    fi

    echo "Enter Test Name (e.g., 'Hgb' or 'BGT' or 'LDL' 'systole' or 'diastol'):"
    read -r test_name

    echo "Enter Test Date (format YYYY-MM):"
    read -r test_date
    # Validate the test date format
    if ! [[ $test_date =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
        echo "Invalid Test Date format. Must be YYYY-MM."
        return
    fi

    echo "Enter Test Result (e.g., '13.5 g/dL'):"
    read -r result

    echo "Enter Test Status (Pending, Completed, Reviewed):"
    read -r status
    # Validate the test status
    if [[ ! "$status" =~ ^(Pending|Completed|Reviewed)$ ]]; then
        echo "Invalid Status. Must be one of 'Pending', 'Completed', or 'Reviewed'."
        return
    fi

    # Append the new record to the file
    echo "$patient_id: $test_name, $test_date, $result, $status" >> "$FILE"
    if [[ $? -eq 0 ]]; then
        echo "Record added successfully."
    else
        echo "Error: Unable to write to $FILE."
    fi
}

# Function to retrieve all tests for a specific patient
retrieve_all_patient_tests() {
    echo "Enter Patient ID (7-digit integer):"
    read -r patient_id
    # Validate that the patient ID is a 7-digit integer
    if ! [[ $patient_id =~ ^[0-9]{7}$ ]]; then
        echo "Invalid Patient ID. Must be a 7-digit integer."
        return
    fi

    echo "All tests for Patient ID $patient_id:"
    grep "^$patient_id:" "$FILE" || echo "No tests found for Patient ID $patient_id."
}

# Function to delete a test record
delete_test_record() {
    echo "Enter Patient ID (7-digit integer):"
    read -r patient_id
    # Validate that the patient ID is a 7-digit integer
    if ! [[ $patient_id =~ ^[0-9]{7}$ ]]; then
        echo "Invalid Patient ID. Must be a 7-digit integer."
        return
    fi

    echo "Enter Test Name (e.g., 'Hgb' or 'BGT'):"
    read -r test_name
    echo "Enter Test Date (format YYYY-MM):"
    read -r test_date
    # Validate the test date format
    if ! [[ $test_date =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
        echo "Invalid Test Date format. Must be YYYY-MM."
        return
    fi

    # Find the existing record for deletion
    existing_record=$(grep "^$patient_id: $test_name, $test_date," "$FILE")
    if [[ -z "$existing_record" ]]; then
        echo "No existing record found for Patient ID $patient_id, Test $test_name on $test_date."
        return
    fi

    echo "Existing record found: $existing_record"
    echo "Are you sure you want to delete this record? (y/n):"
    read -r confirmation
    if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
        # Delete the record by rewriting the file without it
        grep -v "^$existing_record" "$FILE" > temp_file && mv temp_file "$FILE"
        if [[ $? -eq 0 ]]; then
            echo "Record deleted successfully."
        else
            echo "Error: Unable to delete the record."
        fi
    else
        echo "Deletion canceled."
    fi
}

# Function to check if a test result is abnormal
is_abnormal() {
    local test_name="$1"
    local result="$2"
    # Handle different test names and their respective normal ranges
    case "$test_name" in
    "Hgb")
        value=$(echo "$result" | cut -d' ' -f1)
        if (( $(echo "$value < 13.8" | bc -l) || $(echo "$value > 17.2" | bc -l) )); then
            return 0
        fi
        ;;
    "BGT")
        value=$(echo "$result" | cut -d' ' -f1)
        if (( $(echo "$value < 70" | bc -l) || $(echo "$value > 99" | bc -l) )); then
            return 0
        fi
        ;;
    "LDL")
        value=$(echo "$result" | cut -d' ' -f1)
        if (( $(echo "$value >= 100" | bc -l) )); then
            return 0
        fi
        ;;
    "systole")
        value=$(echo "$result" | cut -d' ' -f1)
        if (( $(echo "$value >= 120" | bc -l) )); then
            return 0
        fi
        ;;
    "diastole")
        value=$(echo "$result" | cut -d' ' -f1)
        if (( $(echo "$value >= 80" | bc -l) )); then
            return 0
        fi
        ;;
    esac
    return 1
}

# Function to update an existing test result
update_test_result() {
    echo "Enter Patient ID (7-digit integer):"
    read -r patient_id
    # Validate that the patient ID is a 7-digit integer
    if ! [[ $patient_id =~ ^[0-9]{7}$ ]]; then
        echo "Invalid Patient ID. Must be a 7-digit integer."
        return
    fi

    echo "Enter Test Name (e.g., 'Hgb' or 'BGT'):"
    read -r test_name
    echo "Enter Test Date (format YYYY-MM):"
    read -r test_date
    # Validate the test date format
    if ! [[ $test_date =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
        echo "Invalid Test Date format. Must be YYYY-MM."
        return
    fi

    # Find the existing record for updating
    existing_record=$(grep "^$patient_id: $test_name, $test_date," "$FILE")
    if [[ -z "$existing_record" ]]; then
        echo "No existing record found for Patient ID $patient_id, Test $test_name on $test_date."
        return
    fi

    echo "Existing record found: $existing_record"
    echo "Enter new Test Result (e.g., '14.2 g/dL'):"
    read -r new_result

    echo "Enter new Test Status (Pending, Completed, Reviewed):"
    read -r new_status
    # Validate the test status
    if [[ ! "$new_status" =~ ^(Pending|Completed|Reviewed)$ ]]; then
        echo "Invalid Status. Must be one of 'Pending', 'Completed', or 'Reviewed'."
        return
    fi

    # Replace the old record with the updated one
    updated_record="$patient_id: $test_name, $test_date, $new_result, $new_status"
    sed -i "s|$existing_record|$updated_record|" "$FILE"
    if [[ $? -eq 0 ]]; then
        echo "Record updated successfully."
    else
        echo "Error: Unable to update the record."
    fi
}

# Function to retrieve and display all abnormal tests for a specific patient
retrieve_abnormal_patient_tests() {
    echo "Enter Patient ID (7-digit integer):"
    read -r patient_id
    # Validate that the patient ID is a 7-digit integer
    if ! [[ $patient_id =~ ^[0-9]{7}$ ]]; then
        echo "Invalid Patient ID. Must be a 7-digit integer."
        return
    fi

    echo "Abnormal tests for Patient ID $patient_id:"
    while IFS= read -r line; do
        # Check if the line contains the patient ID
        if [[ "$line" == "$patient_id:"* ]]; then
            # Extract the test name and result from the line
            test_name=$(echo "$line" | cut -d',' -f1 | awk '{print $2}')
            result=$(echo "$line" | cut -d',' -f3)
            if is_abnormal "$test_name" "$result"; then
                echo "$line"
            fi
        fi
    done <"$FILE"
}

# Function to calculate and display the average test value for each patient
calculate_average_test_value() {
    echo "Enter Test Name (e.g., 'Hgb' or 'BGT'):"
    read -r test_name
    # Ensure the test name is valid
    if [[ -z "$test_name" ]]; then
        echo "Invalid Test Name."
        return
    fi

    total=0
    count=0
    while IFS= read -r line; do
        # Extract the test name and result from the line
        line_test_name=$(echo "$line" | cut -d',' -f1 | awk '{print $2}')
        if [[ "$line_test_name" == "$test_name" ]]; then
            result=$(echo "$line" | cut -d',' -f3 | awk '{print $1}')
            total=$(echo "$total + $result" | bc)
            count=$((count + 1))
        fi
    done <"$FILE"

    if [[ $count -gt 0 ]]; then
        average=$(echo "scale=2; $total / $count" | bc)
        echo "The average value of $test_name for all patients is $average."
    else
        echo "No records found for test $test_name."
    fi
}

# Main loop to display the menu and respond to user choices
while true; do
    display_menu
    read -r choice
    case $choice in
    1)
        add_record
        ;;
    2)
        echo "Enter a sub-option (a-e):"
        read -r sub_choice
        case $sub_choice in
        a)
            retrieve_all_patient_tests
            ;;
        b)
            retrieve_abnormal_patient_tests
            ;;
        # Add additional cases for other sub-options as needed
        *)
            echo "Invalid sub-option."
            ;;
        esac
        ;;
    3)
        calculate_average_test_value
        ;;
    4)
        delete_test_record
        ;;
    5)
        update_test_result
        ;;
    6)
        calculate_average_test_value
        ;;
    7)
        echo "Exiting the program."
        exit 0
        ;;
    *)
        echo "Invalid option."
        ;;
    esac
    echo "Press Enter to continue..."
    read
done

