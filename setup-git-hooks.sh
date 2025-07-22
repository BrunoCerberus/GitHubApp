#!/bin/sh

# Symlink the versioned pre-commit hook
ln -sf ../../.githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "Git hooks installed!" 