.PHONY: build build-typecheck bundle_install cicoverage citypecheck citest citypecoverage clean clean-coverage clean-typecheck clean-typecoverage coverage default feature gem_dependencies help overcommit quality repl report-coverage rubocop rubocop-ratchet spec test typecheck typecoverage update_from_cookiecutter
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

default: clean-typecoverage build typecheck typecoverage clean-coverage test coverage overcommit_branch quality rubocop-ratchet ## run default typechecking, tests and quality

SOURCE_FILE_GLOBS = ['{config,lib,app,script}/**/*.rb', 'ext/**/*.{c,rb}']

SOURCE_FILES := $(shell ruby -e "puts Dir.glob($(SOURCE_FILE_GLOBS))")

start: ## run code continously and watch files for changes
	echo "Teach me how to 'make start'"
	exit 1

rbi/checkoff.rbi: yardoc.installed ## Generate Sorbet types from Yard docs
	rm -f rbi/checkoff.rbi
	bin/sord gen --replace-errors-with-untyped --exclude-messages OMIT --no-regenerate rbi/checkoff.rbi

sig/checkoff.rbs: yardoc.installed ## Generate RBS file
	bundle exec sord --replace-errors-with-untyped --exclude-messages OMIT --no-regenerate sig/checkoff.rbs

types.installed: tapioca.installed Gemfile.lock Gemfile.lock.installed rbi/checkoff.rbi sorbet/tapioca/require.rb sorbet/config ## Ensure typechecking dependencies are in place
	bin/yard gems 2>&1 || bin/yard gems --safe 2>&1 || bin/yard gems 2>&1
	# bin/solargraph scan 2>&1
	bin/spoom srb bump || true
	# spoom rudely updates timestamps on files, so let's keep up by
	# touching yardoc.installed so we don't end up in a vicious
	# cycle
	touch yardoc.installed rbi/checkoff.rbi
	# bin/solargraph scan 2>&1
	touch types.installed

build: bundle_install pip_install build-typecheck ## Update 3rd party packages as well and produce any artifacts needed from code

sorbet/machine_specific_config:
	echo "--cache-dir=$$HOME/.sorbet-cache" > sorbet/machine_specific_config

sorbet/rbi/todo.rbi: rbi/checkoff.rbi tapioca.installed
	bin/tapioca todo

build-typecheck: Gemfile.lock.installed types.installed sorbet/machine_specific_config sorbet/rbi/todo.rbi ## Fetch information that type checking depends on

# Only create this once, so no dependencies
sorbet/tapioca/require.rb:
	make sorbet/machine_specific_config vendor/.keep
	bin/tapioca init

tapioca.installed: sorbet/tapioca/require.rb Gemfile.lock.installed ## Install Tapioca-generated type information
	make sorbet/machine_specific_config
	bin/tapioca gems
	bin/tapioca annotations
#	bin/tapioca dsl
	touch tapioca.installed

yardoc.installed: $(wildcard config/annotations_*.rb) $(SOURCE_FILES) ## Generate YARD documentation
	bin/yard doc -c .yardoc $^
	touch yardoc.installed

clean-typecheck: ## Refresh the easily-regenerated information that type checking depends on
	bin/solargraph clear || true
	rm -fr .yardoc/ rbi/checkoff.rbi types.installed yardoc.installed
	rm -fr ../checkoff/.yardoc || true
	echo all clear

realclean-typecheck: clean-typecheck ## Remove all type checking artifacts
	rm -fr ~/.cache/solargraph
	rm tapioca.installed

realclean: clean realclean-typecheck
	rm -fr vendor/bundle .bundle
	rm -f .make/*
	rm *.installed

typecheck: build-typecheck ## validate types in code and configuration
	bin/srb tc
	bin/solargraph typecheck --level strong

citypecheck: build-typecheck ## Run type check from CircleCI
	bin/srb tc
	bin/solargraph typecheck --level strong

typecoverage: typecheck ## Run type checking and then ratchet coverage in metrics/

clean-typecoverage: ## Clean out type-related coverage previous results to avoid flaky results

citypecoverage: citypecheck ## Run type checking, ratchet coverage, and then complain if ratchet needs to be committed

config/env: config/env.1p  ## Create file suitable for docker-compose usage
	cat config/env.1p | cut -d= -f1 > config/env

requirements_dev.txt.installed: requirements_dev.txt
	pip install -q --disable-pip-version-check -r requirements_dev.txt
	touch requirements_dev.txt.installed

pip_install: requirements_dev.txt.installed ## Install Python dependencies

Gemfile.lock: Gemfile checkoff.gemspec .bundle/config
	bundle lock

.bundle/config:
	touch .bundle/config

gem_dependencies: .bundle/config

# Ensure any Gemfile.lock changes, even pulled from git, ensure a
# bundle is installed.
Gemfile.lock.installed: Gemfile checkoff.gemspec vendor/.keep
	bundle install
	touch Gemfile.lock.installed

vendor/.keep: Gemfile.lock .ruby-version
	make gem_dependencies
	bundle install
	touch vendor/.keep

bundle_install: Gemfile.lock.installed ## Install Ruby dependencies

clear_metrics: ## remove or reset result artifacts created by tests and quality tools
	bin/rake clear_metrics || true

clean: clear_metrics clean-typecoverage clean-typecheck clean-coverage ## remove all built artifacts

test: spec feature ## run tests quickly

citest: test ## Run unit tests from CircleCI

overcommit: ## run precommit quality checks
	bin/overcommit --run

overcommit_branch: ## run precommit quality checks only on changed files
	@bin/overcommit_branch

quality: overcommit ## run precommit quality checks

rubocop: ## Run rubocop
	@bin/rubocop

rubocop-ratchet: rubocop ## Run rubocop and then ratchet numbers of errors in todo file
	@bin/rubocop --regenerate-todo --no-exclude-limit --auto-gen-only-exclude --no-auto-gen-timestamp
	@if [ -f .rubocop_todo.yml ]; \
	  then \
	    git diff --exit-code .rubocop.yml; \
	    git diff --exit-code .rubocop_todo.yml; \
	fi

spec: ## Run lower-level tests
	@bin/rake spec

feature: ## Run higher-level tests
	@bin/rake feature

repl: bundle_install ## Launch an interactive development shell
	@bin/rake repl

clean-coverage: clear_metrics ## Clean out previous output of test coverage to avoid flaky results from previous runs

coverage: test report-coverage ## check code coverage
	@bin/rake undercover

release: sig/checkoff.rbs rbi/checkoff.rbi ## Create a new release
	bundle exec rake release

report-coverage: test ## Report summary of coverage to stdout, and generate HTML, XML coverage report

update_apt: .make/apt_updated

.make/apt_updated:
	sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
	touch .make/apt_updated

cicoverage: citest coverage ## check code coverage

update_from_cookiecutter: ## Bring in changes from template project used to create this repo
	bin/overcommit --uninstall
	# cookiecutter_project_upgrader does its work in
	# .git/cookiecutter/checkoff, but RuboCop wants to inherit
	# config from all directories above it - avoid config
	# mismatches by moving this out of the way
	mv .rubocop.yml .rubocop-renamed.yml || true
	cookiecutter_project_upgrader --help >/dev/null
	IN_COOKIECUTTER_PROJECT_UPGRADER=1 cookiecutter_project_upgrader || true
	mv .rubocop-renamed.yml .rubocop.yml
	git checkout cookiecutter-template && git push --no-verify
	git checkout main; overcommit --sign && overcommit --sign pre-commit && overcommit --sign pre-push && git checkout main && git pull && git checkout -b update-from-cookiecutter-$$(date +%Y-%m-%d-%H%M)
	git merge cookiecutter-template || true
	git checkout --theirs sorbet/rbi/gems || true
	git checkout --ours Gemfile.lock || true
	# update frequently security-flagged gems while we're here
	bundle update --conservative json rexml yard brakeman || true
	( make build && git add Gemfile.lock ) || true
	bin/spoom srb bump || true
	bin/overcommit --install || true
	@echo
	@echo "Please resolve any merge conflicts below and push up a PR with:"
	@echo
	@echo '   gh pr create --title "Update from cookiecutter" --body "Automated PR to update from cookiecutter boilerplate"'
	@echo
	@echo
