tell application "iTerm"
	create window with default profile
	tell current session of current window
		set columns to 300
		set rows to 40
		split horizontally with default profile command "bash -c 'source ~/.bashrc; eval \"$(rbenv init -)\"; set -ex; sleep 1 && ( clear; cd boots-cats-ruby && rbenv local 3.2.4; bundle install && ./bin/server ) ; sleep 100'"
		split vertically with default profile command "bash -c 'source ~/.bashrc; set -ex; pwd -P; sleep 3 && ( clear; cd boots-cats-js && ./bin/ai-client ) ; sleep 100''"
		split vertically with default profile command "bash -c 'source ~/.bashrc; set -ex; pwd -P; sleep 5 && ( clear; cd boots-cats-js && ./bin/ai-client ); sleep 100''"
	end tell
end tell
