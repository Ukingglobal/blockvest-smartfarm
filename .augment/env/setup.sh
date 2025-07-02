#!/bin/bash

# First, let's explore the codebase structure to understand what we're working with
echo "=== Codebase Analysis ==="
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la

echo -e "\n=== Finding all files recursively ==="
find . -type f -name "*" | head -20

echo -e "\n=== Looking for common configuration files ==="
find . -name "package.json" -o -name "requirements.txt" -o -name "go.mod" -o -name "Cargo.toml" -o -name "pom.xml" -o -name "build.gradle" -o -name "setup.py" -o -name "pyproject.toml" -o -name "Makefile" -o -name "CMakeLists.txt" -o -name "Dockerfile" -o -name "docker-compose.yml" -o -name "composer.json" -o -name "Gemfile"

echo -e "\n=== Looking for source code files ==="
find . -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" -o -name "*.cs" -o -name "*.rb" -o -name "*.php" | head -10

echo -e "\n=== Looking for test directories and files ==="
find . -type d -name "*test*" -o -name "*spec*"
find . -name "*test*.py" -o -name "*test*.js" -o -name "*test*.go" -o -name "*_test.py" -o -name "*_test.js" -o -name "*_test.go" -o -name "test_*.py" | head -10