.PHONY: spec feature

all: localtest

localtest:
	@bundle exec rake localtest

feature:
	@bundle exec rake feature

spec:
	@bundle exec rake spec

rubocop:
	@bundle exec rake rubocop

punchlist:
	@bundle exec rake punchlist

pronto:
	@bundle exec rake pronto

bigfiles:
	@bundle exec rake bigfiles

quality:
	@bundle exec rake quality

update_from_cookiecutter: ## Bring in changes from template project used to create this repo
	IN_COOKIECUTTER_PROJECT_UPGRADER=1 cookiecutter_project_upgrader || true
	git checkout cookiecutter-template && git push && (git checkout main; bundle exec overcommit --sign)
	git checkout main && bundle exec overcommit --sign && git pull && (git checkout -b update-from-cookiecutter-$$(date +%Y-%m-%d-%H%M); bundle exec overcommit --sign)
	git merge cookiecutter-template || true
	@echo
	@echo "Please resolve any merge conflicts below and push up a PR with:"
	@echo
	@echo '   gh pr create --title "Update from cookiecutter" --body "Automated PR to update from cookiecutter boilerplate"'
	@echo
	@echo
