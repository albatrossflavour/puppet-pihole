# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Puppet module called `albatrossflavour-pihole` (v0.1.0) for installing, configuring, and managing Pi-hole DNS ad-blocking software. The module supports various Linux distributions including CentOS, RHEL, Debian, and Ubuntu.

## Development Commands

All Ruby/Puppet development commands should be prefixed with `pdk bundle exec` to use the Puppet Development Kit:

### Testing and Validation
- `pdk bundle exec rake spec` - Run RSpec tests
- `pdk bundle exec rake lint` - Run puppet-lint checks
- `pdk bundle exec rake syntax` - Check Puppet syntax
- `pdk bundle exec rake validate` - Run validation checks
- `pdk bundle exec rake metadata_lint` - Validate metadata.json

### Code Quality
- `pdk bundle exec rubocop` - Run Ruby style checks
- `pdk bundle exec puppet-lint manifests/` - Lint Puppet manifests directly

### Documentation
- `pdk bundle exec rake strings:generate` - Generate REFERENCE.md from code comments (if puppet-strings is available)

## Code Architecture

### Module Structure
- `manifests/` - Puppet manifests (currently contains only `init.pp` with basic class structure)
- `spec/` - RSpec tests for Puppet code
- `data/` - Hiera data files
- `tasks/` - Puppet tasks for operational commands
- `templates/` - ERB templates for configuration files
- `files/` - Static files managed by the module

### Key Configuration Files
- `metadata.json` - Module metadata including supported OS versions and Puppet version requirements (>= 7.24 < 9.0.0)
- `hiera.yaml` - Hiera configuration for data lookup
- `.puppet-lint.rc` - Puppet linting configuration with specific rule overrides
- `Rakefile` - Ruby build tasks with puppet-lint configuration

### Testing Framework
- Uses RSpec with rspec-puppet for unit testing
- `spec/spec_helper.rb` configures test environment with puppetlabs_spec_helper
- Tests are located in `spec/classes/` following standard Puppet testing patterns

### Linting Configuration
The module has customised puppet-lint settings that disable several standard checks:
- 80/140 character line limits disabled
- Documentation checks disabled
- Various style checks relaxed for practical development

## Supported Operating Systems

As defined in metadata.json:
- CentOS 7, 8, 9
- RHEL 7, 8, 9
- Debian 10, 11, 12
- Ubuntu 18.04, 20.04, 22.04
- Oracle Linux 7
- Scientific Linux 7
- Rocky Linux 8
- AlmaLinux 8
- All code in this repo must pass `pdk validate` and other standard `rake` tests **BEFORE** it gets committed
- do not use `exec` statements unless I specifically say you can
- use puppet best practices and coding standards
- make sure we keep the metadata.json up to date with any dependancies, and also update fixtures etc
- All puppet files must contain puppet strings documentation and all parameters must be typed with sane default
