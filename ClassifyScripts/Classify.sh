#!/bin/bash

# Define a function to run a Python file
run_python_file() {
    echo "Running $1 ..."
    python $1
    echo "$1 has finished running!"
}

# Display a menu for the user to choose from
echo "Please select the Python file you want to run:"
echo "1. Deep_features_classification.py"
echo "2. Graph_features_classification.py"
echo "3. HandCrafted_features_classification.py"
echo "4. Run all files"
echo "5. Exit"

# Read the user's choice
read -p "Enter your choice (1/2/3/4/5): " choice

# Execute the corresponding action based on the user's choice
case $choice in
    1)
        run_python_file "Deep_features_classification.py"
        ;;
    2)
        run_python_file "Graph_features_classification.py"
        ;;
    3)
        run_python_file "HandCrafted_features_classification.py"
        ;;
    4)
        run_python_file "Deep_features_classification.py"
        run_python_file "Graph_features_classification.py"
        run_python_file "HandCrafted_features_classification.py"
        ;;
    5)
        echo "Exiting the program"
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
