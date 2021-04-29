# scalr_api
Shell script for simplifying SCALR API calls. The SCALR API requires that a hash of the request be created using the API key secret and included in a header with the request (making Postman collections difficult). This script will build, and execute, the request via curl. Some quality of life features are included to make working with specific servers in a farm easier.

Installation

	curl -o https://raw.githubusercontent.com/tguy-ping/scalr_api/main/scalr_tools.sh
	chmod +x ./scalr_tools.sh

Usage: 

	./scalr_tools.sh <task> [-a <scalr-api-url>...] [<action>] [<server-id>]

Task:

	server-action		Executes request based on supplied action and server
	request			Executes request based on supplied HTTP method, API path, and optional query string and body
	signature		Prints signature based on supplied HTTP method, API path, and optional query string and body
Flags (overrides environment variables):
  
  	Use with any task. If environment variables are not set, all options are required

	-a    |  --server 	SCALR host. Overwrites $SCALR_API_SERVER
				Example: https://scalr.example.com
	-k    |  --api-key	Key with permissions for server/farm. Overwrites $SCALR_API_KEY
	-s    |  --api-secret	Secret with permissions for server/farm. Overwrites $SCALR_API_SECRET
	-e    |  --env-id	Environment id. Overwrites $SCALR_ENV_ID
	-sid  |  --server-id	Server id of target. Overwrites $SCALR_SERVER_ID
Actions:

	status
	resume
	suspend
	sync
	terminate
Examples:

	./scalr_tools.sh server-action -a https://scalr.example.com -k xxxxx -s xxxxx --env-id x resume xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
	
Environment variables checked:

	SCALR_API_SERVER
	SCALR_API_KEY
	SCALR_API_SECRET
	SCALR_ENV_ID
	SCALR_SERVER_ID
