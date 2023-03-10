#!/bin/bash

# Get date and time for output file generation
datetime=$(date +"%Y-%m-%d_%H-%M")

# Ask for input
echo "Please enter the API key for the apps that you want to extract"

# Read input to a variable
read key

if [ ! -d "$(pwd)/logs" ]; then
    mkdir "$(pwd)/logs"
fi

# Using an API request write the keys to a file
chmod +x get_app_codes.sh
./get_app_codes.sh "$key" "$datetime"  2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "$(pwd)/logs/logfile_${datetime}.log"

# Parse the file and generate the export requests
chmod +x generate_export_requests.sh
./generate_export_requests.sh "$key" "$datetime"  2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "$(pwd)/logs/logfile_${datetime}.log"

# Export the segments
chmod +x "export_requests_${datetime}.sh"
./"export_requests_${datetime}.sh" 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "$(pwd)/logs/logfile_${datetime}.log"

# Parse the file and generate the process requests
chmod +x generate_process_requests.sh
./generate_process_requests.sh "$key" "$datetime"  2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "$(pwd)/logs/logfile_${datetime}.log"

# Process the segments
chmod +x "process_requests_${datetime}.sh"
./"process_requests_${datetime}.sh" "$key"  "$datetime"  2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "$(pwd)/logs/logfile_${datetime}.log"

# Save the .csv.zip to a back up folder
chmod +x backup.sh
./backup.sh "$datetime"

# Delete the temporary files
chmod +x clean_temp_files.sh
./clean_temp_files.sh
