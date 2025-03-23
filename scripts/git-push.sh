#!/bin/bash

# Check if a commit message was provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide a commit message"
    echo "Usage: $0 \"your commit message\""
    exit 1
fi

# Get the commit message from the first argument
commit_message="$1"

# Stage all changes
git add -A

# Commit with the provided message
git commit -m "$commit_message"

# Push to origin main
git push origin main

echo "Changes have been staged, committed, and pushed to origin main"
