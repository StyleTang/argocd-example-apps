#!/bin/bash

# Check the number of arguments passed
if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
    echo "Usage: $0 <target_application> <application_to_modify> <action(add|delete)> <project> [optional_id]"
    exit 1
fi

# Get the passed arguments
target_application=$1
application_to_modify=$2
action=$3
project=$4
optional_id=${5:-}

# Fetch JSON data
echo "Fetching JSON data..."
json_output=$(argocd proj windows list $project -o json)
echo "JSON data fetched:"
echo "$json_output"

# Identify the rule with the target application
echo "Identifying the rule containing target application '$target_application'..."
rule=$(echo "$json_output" | jq --arg app "$target_application" '
  to_entries
  | map(.value + {id: (.key|tostring)})
  | map(select(.applications[] == $app))
  | .[0]
')
if [ -z "$rule" ] || [ "$rule" == "null" ]; then
    echo "Error: No rule found containing application '$target_application'."
    exit 1
fi
echo "Rule identified:"
echo "$rule"

# Get the rule ID
echo "Extracting rule ID..."
id=$(echo "$rule" | jq -r '.id')
echo "Rule ID: $id"

# Validate the optional ID parameter
if [ -n "$optional_id" ] && [ "$id" != "$optional_id" ]; then
    echo "Error: Provided ID ($optional_id) does not match the system returned ID ($id)."
    exit 1
fi

# Modify the applications list based on the action type
if [ "$action" == "delete" ]; then
    echo "Deleting application '$application_to_modify' from the applications list..."
    updated_applications=$(echo "$rule" | jq --arg app "$application_to_modify" '.applications | map(select(. != $app))')
elif [ "$action" == "add" ]; then
    echo "Adding application '$application_to_modify' to the applications list..."
    updated_applications=$(echo "$rule" | jq --arg app "$application_to_modify" '.applications + [$app] | unique')
else
    echo "Invalid action: $action. Please use 'add' or 'delete'."
    exit 1
fi
echo "Updated applications list:"
echo "$updated_applications"

# Update the rule using ArgoCD
echo "Updating the rule using ArgoCD..."
argocd proj windows update $project $id --applications "$(echo $updated_applications | jq -r 'join(",")')"
update_result=$?
if [ $update_result -ne 0 ]; then
    echo "Failed to update the rule."
    exit 1
fi

echo "Rule ID $id updated successfully with applications: $(echo $updated_applications | jq -r 'join(",")')"
