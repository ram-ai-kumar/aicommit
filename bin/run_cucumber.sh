#!/bin/bash
# Simple Cucumber test runner for aicommit
set -e

cd "$(dirname "$0")/.."

# Set up Ruby environment
export BUNDLE_GEMFILE="$(pwd)/Gemfile"
export BUNDLE_PATH="$(pwd)/.bundle"

# Run Cucumber with basic options
bundle exec cucumber --format pretty --color "$@"
