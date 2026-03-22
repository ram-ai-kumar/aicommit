# Testing Guide

## Running Cucumber Tests with Bundle Exec

Use `bundle exec cucumber` with tags instead of the custom shell script for better Ruby ecosystem integration.

### Quick Start

```bash
# Install dependencies
bundle install

# Run all tests
bundle exec cucumber

# Run specific categories
bundle exec cucumber --tags @functional
bundle exec cucumber --tags @security
bundle exec cucumber --tags @compliance
bundle exec cucumber --tags @risk
bundle exec cucumber --tags @governance
```

### Available Tags

| Tag | Description | Feature Files |
|-----|-------------|---------------|
| `@functional` | Core functionality tests | `features/functional/*.feature` |
| `@security` | Security and Zero Trust tests | `features/security/*.feature` |
| `@compliance` | Regulatory compliance tests | `features/compliance/*.feature` |
| `@risk` | Risk management tests | `features/risk_management/*.feature` |
| `@governance` | Business value tests | `features/governance/*.feature` |
| `@smoke` | Basic smoke tests | `features/functional/basic_functionality.feature` |
| `@critical` | Critical security/compliance tests | Security, compliance, risk, governance |
| `@zero-trust` | Zero Trust Architecture tests | `features/security/trust_and_safety.feature` |

### Test Profiles

Use cucumber.yml profiles for predefined configurations:

```bash
# Run functional tests with HTML output
bundle exec cucumber -p functional

# Run security tests with HTML output  
bundle exec cucumber -p security

# Run all tests with full reporting
bundle exec cucumber -p all

# Run smoke tests only
bundle exec cucumber -p smoke

# Run critical tests
bundle exec cucumber -p critical
```

### Examples

```bash
# Run smoke tests (basic functionality)
bundle exec cucumber --tags @smoke

# Run all security and compliance tests
bundle exec cucumber --tags @security,@compliance

# Run critical tests with pretty format
bundle exec cucumber --tags @critical --format pretty

# Run tests and generate HTML report
bundle exec cucumber --tags @functional --format html --out test-results/functional.html

# Dry run to check syntax
bundle exec cucumber --dry-run --tags @security
```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Run Tests
  run: |
    bundle install --without development
    bundle exec cucumber --tags @smoke --format junit --out test-results/
    bundle exec cucumber --tags @security --format json --out security-results.json
```

### Development Workflow

1. **Before committing**: Run smoke tests
   ```bash
   bundle exec cucumber --tags @smoke
   ```

2. **Before release**: Run full test suite
   ```bash
   bundle exec cucumber -p all
   ```

3. **Security review**: Run security and compliance tests
   ```bash
   bundle exec cucumber --tags @security,@compliance
   ```

### Troubleshooting

```bash
# Check for syntax errors
bundle exec cucumber --dry-run

# Run specific feature file
bundle exec cucumber features/functional/basic_functionality.feature

# Run with verbose output
bundle exec cucumber --verbose --tags @smoke
```

This approach provides better integration with the Ruby ecosystem and eliminates the need for custom shell scripts.
