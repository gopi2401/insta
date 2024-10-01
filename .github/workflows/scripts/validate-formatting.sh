#!/bin/bash

# Format the files first
echo "🔧 Attempting to auto-format files..."
cd ..
cd ..
cd ..
melos run format

# Check for any remaining modified files
if [[ $(git ls-files --modified) ]]; then
    echo ""
    echo ""
    echo "These files are still not formatted correctly:"
    for f in $(git ls-files --modified); do
        echo ""
        echo ""
        echo "-----------------------------------------------------------------"
        echo "$f"
        echo "-----------------------------------------------------------------"
        echo ""
        git --no-pager diff --unified=0 --minimal $f
        echo ""
        echo "-----------------------------------------------------------------"
        echo ""
        echo ""
    done
    if [[ $GITHUB_WORKFLOW ]]; then
        git checkout . > /dev/null 2>&1
    fi
    echo ""
    echo "❌ Some files are incorrectly formatted, see above output."
    echo ""
    echo "To manually fix these, run: 'melos run format' again or inspect the changes."
    exit 1
else
    echo ""
    echo "✅ All files are formatted correctly."
fi
