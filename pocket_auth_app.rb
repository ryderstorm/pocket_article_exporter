# frozen_string_literal: true

# Description: This is a simple app that will allow you to authenticate with Pocket
# and retrieve your article list. It is intended to be used as a starting point for
# building your own Pocket app.
#
# This app uses the Sinatra web framework. You can find more information about
# Sinatra at http://www.sinatrarb.com/
#
# This app uses the HTTParty gem to make HTTP requests. You can find more
# information about HTTParty at
#

require './lib/pocket_api'
require './lib/web_server'

# Set process ID file so that the app can be easily killed and reloaded
# See note in ./bin/start.sh
File.write('pocket_auth_app_pid.txt', Process.pid)

# Start the web server
PocketServer.run!
