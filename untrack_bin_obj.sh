#!/bin/bash
# This script will untrack bin and obj files but leave them on disk

# Find all bin and obj files currently tracked in git
git ls-files | grep -E '(bin/|obj/)' > files_to_untrack.txt

# Untrack each file individually
while IFS= read -r file; do
    git rm --cached "$file"
done < files_to_untrack.txt

# Clean up
rm files_to_untrack.txt

echo "All bin and obj files have been removed from git tracking but kept on disk."
echo "You should now commit the .gitignore file and these changes."
