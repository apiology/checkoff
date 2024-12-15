.PHONY: build-typecheck bundle_install cicoverage citypecheck citest citypecoverage clean clean-coverage clean-typecheck clean-typecoverage coverage default help localtest overcommit quality repl report-coverage report-coverage-to-codecov rubocop test typecheck typecoverage update_from_cookiecutter
.DEFAULT_GOAL := default

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

default: clean-typecoverage typecheck typecoverage clean-coverage test coverage quality ## run default typechecking, tests and quality

config/defs.rbi: .yardoc/complete ## Generate RBS files
	rm -f config/defs.rbi
	bundle exec sord --replace-errors-with-untyped --no-regenerate config/defs.rbi

build-typecheck: Gemfile.lock.installed types.installed config/defs.rbi ## Fetch information that type checking depends on

types.installed: tapioca.installed Gemfile.lock Gemfile.lock.installed ## Install Ruby dependencies
	bundle exec yard gems 2>&1 || bundle exec yard gems --safe 2>&1 || bundle exec yard gems 2>&1
	# bundle exec solargraph scan 2>&1
	touch types.installed

sorbet/tapioca/require.rb:
	bin/tapioca init

tapioca.installed: sorbet/tapioca/require.rb Gemfile.lock.installed ## Install Tapioca-generated type information
	bin/tapioca gems
	bin/tapioca annotations
#	bin/tapioca dsl
	bin/tapioca todo
	touch tapioca.installed

SOURCE_FILES = $(shell find lib -name '*.rb' -type f)

.yardoc/complete: $(wildcard config/annotations_*.rb) $(SOURCE_FILES) ## Generate YARD documentation
	bin/yard -c

clean-typecheck: ## Refresh the easily-regenerated information that type checking depends on
	bin/solargraph clear
	rm -fr .yardoc/ config/defs.rbi types.installed
	echo all clear

realclean-typecheck: clean-typecheck ## Remove all type checking artifacts
	rm tapioca.installed

typecheck: build-typecheck ## validate types in code and configuration
#	bin/tapioca dsl --verify
	bundle exec srb tc
	bin/overcommit_branch # ideally this would just run solargraph

citypecheck: typecheck ## Run type check from CircleCI
	bundle exec solargraph typecheck --level strong

typecoverage: typecheck ## Run type checking and then ratchet coverage in metrics/

clean-typecoverage: ## Clean out type-related coverage previous results to avoid flaky results

citypecoverage: typecoverage ## Run type checking, ratchet coverage, and then complain if ratchet needs to be committed

requirements_dev.txt.installed: requirements_dev.txt
	pip install -q --disable-pip-version-check -r requirements_dev.txt
	touch requirements_dev.txt.installed

pip_install: requirements_dev.txt.installed ## Install Python dependencies

Gemfile.lock: Gemfile checkoff.gemspec
	bundle lock

# Ensure any Gemfile.lock changes, even pulled form git, ensure a
# bundle is installed.
Gemfile.lock.installed: Gemfile.lock Gemfile checkoff.gemspec
	bundle install
	touch Gemfile.lock.installed

bundle_install: Gemfile.lock.installed ## Install Ruby dependencies

clear_metrics: ## remove or reset result artifacts created by tests and quality tools
	bundle exec rake clear_metrics

clean: clear_metrics ## remove all built artifacts

citest: test ## Run unit tests from CircleCI

overcommit: ## run precommit quality checks
	bin/overcommit_branch

quality: overcommit ## run precommit quality checks

test: ## Run lower-level tests
	@bundle exec rake test

localtest: ## run default local actions
	@bundle exec rake localtest

repl: bundle_install ## Load up plate-spinner in pry
	@bundle exec rake repl

clean-coverage:
	@bundle exec rake clear_metrics

coverage: test report-coverage ## check code coverage
	@bundle exec rake undercover

report-coverage: test ## Report summary of coverage to stdout, and generate HTML, XML coverage report

cicoverage: coverage ## check code coverage

update_from_cookiecutter: ## Bring in changes from template project used to create this repo
	bundle exec overcommit --uninstall
	# cookiecutter_project_upgrader does its work in
	# .git/cookiecutter/checkoff, but RuboCop wants to inherit
	# config from all directories above it - avoid config
	# mismatches by moving this out of the way
	mv .rubocop.yml .rubocop-renamed.yml || true
	cookiecutter_project_upgrader --help >/dev/null
	IN_COOKIECUTTER_PROJECT_UPGRADER=1 cookiecutter_project_upgrader || true
	mv .rubocop-renamed.yml .rubocop.yml
	git checkout cookiecutter-template && git push --no-verify
	git checkout main; overcommit --sign && overcommit --sign pre-commit && git checkout main && git pull && git checkout -b update-from-cookiecutter-$$(date +%Y-%m-%d-%H%M)
	git merge cookiecutter-template || true
	git checkout --ours Gemfile.lock || true
	# update frequently security-flagged gems while we're here
	bundle update --conservative nokogiri rack rexml yard || true
	make build-typecheck
	git add Gemfile.lock || true
	bundle install || true
	bundle exec overcommit --install || true
	@echo
	@echo "Please resolve any merge conflicts below and push up a PR with:"
	@echo
	@echo '   gh pr create --title "Update from cookiecutter" --body "Automated PR to update from cookiecutter boilerplate"'
	@echo
	@echo
