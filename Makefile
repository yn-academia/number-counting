# vim: ft=make
# vim: tabstop=8
# vim: shiftwidth=8
# vim: noexpandtab

# grep '^[a-z\-]*:' Makefile | cut -d: -f 1 | tr '\n' ' '
.PHONY:	 build, check-port, foreman-ai, foreman-cli, help, iterm-ai, iterm-cli, js-install, ruby-all, ruby-install, ruby-lint, ruby-lint-fix, ruby-rspec

default: help

# see: https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile/18137056#18137056
MAKEFILE_PATH 	:= $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR 	:= $(shell ( cd .; pwd -P ) )
PORT 		:= 7535

help:	   	## Prints help message auto-generated from the comments.
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sort

js-install: 	## Setup the JS clients
		@cd boots-cats-js && yarn install && echo && cd -

ruby-install:	## Setup the Ruby Server
		@cd boots-cats-ruby && (bundle check || bundle install); echo; cd -

ruby-lint:	ruby-install ## Run ruby checks such as rubocop
		@cd boots-cats-ruby && bundle exec rubocop --parallel && cd -

ruby-lint-fix:	ruby-install ## Auto-fix with Rubocop all fixable errors and regenerate auto-config-file
		@cd boots-cats-ruby && bundle exec rubocop -a && bundle exec rubocop --auto-gen-config; rubocop --parallel; cd -

ruby-rspec:	ruby-install ## Runs the Ruby RSpec tests for the server
		@cd boots-cats-ruby && bundle exec rspec --format progress && cd -

ruby-all:	ruby-install ruby-lint ruby-rspec ## Installs Ruby Gems, runs RSpec and Rubocop.

build:		foreman js-install ruby-all ## Install Ruby and JS dependencies and run the all the tests and linters
		
foreman:
		@echo "INFO: Installing Foreman..."
		@gem list | grep foreman || gem install foreman -N
		@echo

check-port:	## Verifies that nobody is already attached to the server's port
		@netstat -an | grep -z :$(PORT) && { echo "ERROR: Port $(PORT) is already in use!"; exit 1; } || echo "OK: Port $(PORT) is available..."
		@echo
		
foreman-ai: 	check-port ruby-install js-install foreman ## Use Foreman to start a server + several AI clients
		@echo "INFO: Starting Ruby Server and 3 JS AI Clients..."; sleep 1
		@foreman start -f config/Procfile.ai
		@echo

iterm-cli:	check-port ruby-install js-install ## Use AppleScript & iTerm2 to start a server + several CLI clients
		@echo "INFO: Starting Ruby Server and 2 JS CLI Clients..."; sleep 1
		@osascript config/iterm2-cli.applescript
		@echo

iterm-ai: 	check-port ruby-install js-install ## Use AppleScript & iTerm2 to start a server + several AI clients
		@echo "INFO: Starting Ruby Server and 2 JS AI Clients..."; sleep 1
		@osascript config/iterm2-ai.applescript
		@echo

