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
