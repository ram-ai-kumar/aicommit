# BDD Testing with Cucumber-Ruby

This directory contains Cucumber BDD tests for the aicommit project using Ruby and Gherkin.

## Setup

1. **Install Dependencies**

   ```bash
   bundle install
   ```

2. **Run Tests**

   ```bash
   # Use the custom runner script
   ./bin/run_cucumber.sh features/security/zero_trust_architecture.feature

   # Or run directly with bundle exec
   BUNDLE_PATH=./vendor/bundle bundle exec cucumber features/security/zero_trust_architecture.feature
   ```

## Features

### Security Features

- `features/security/zero_trust_architecture.feature` - Zero Trust Architecture validation
- `features/security/sample_security.feature` - Sample security test

### Workflow Features

- `features/workflows/conventional_commits.feature` - Conventional commit generation

## Step Definitions

- `features/step_definitions/security_steps.rb` - Security-related step definitions
- `features/step_definitions/workflow_steps.rb` - Workflow step definitions

## Configuration

- `features/support/env.rb` - Cucumber environment setup
- `cucumber.yml` - Cucumber configuration
- `Gemfile` - Ruby dependencies

## Notes

- Uses Ruby 4.0.2 with Cucumber 10.2.0
- RSpec matchers for assertions
- BATS integration still works alongside BDD tests

## Running Tests

```bash
# Run all features
./bin/run_cucumber.sh

# Run specific feature
./bin/run_cucumber.sh features/security/zero_trust_architecture.feature

# Run with specific tags
./bin/run_cucumber.sh --tags @security
```
