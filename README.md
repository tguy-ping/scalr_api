# scalr_api
Shell script for simplifying SCALR API (v2) calls. The SCALR API requires that a hash of the request be created using the API key secret and included in a header with the request. This script will build, and execute, the request via curl. Some quality of life functions are included to make working with specific servers in a farm easier. You can request an API key from https://\<your-scalr-host\>/#/core/api2
	
More information about the SCALR API is available here: https://api-explorer.scalr.com/

Installation

	curl -o 'scalr_tools.sh' 'https://raw.githubusercontent.com/tguy-ping/scalr_api/main/scalr_tools.sh'
	chmod +x ./scalr_tools.sh

Usage: 

	./scalr_tools.sh <task> [-a <scalr-api-url>...] [<action>] [<server-id>]

Task:

	server-action		Executes request based on supplied action and server.
				Actions available:
					status
					resume
					suspend
					sync
					terminate
	request			Executes request based on supplied HTTP method, API path,
					and optional query string and body
	signature		Prints signature based on supplied HTTP method, API path,
					and optional query string and body
Flags (overrides environment variables):
  
  	Use with any task. If environment variables are not set, all options are required

	-a    |  --server 	SCALR host. 		Overwrites $SCALR_API_SERVER
	-k    |  --api-key	API key ID 		Overwrites $SCALR_API_KEY
	-s    |  --api-secret	API key secret		Overwrites $SCALR_API_SECRET
	-e    |  --env-id	Environment id. 	Overwrites $SCALR_ENV_ID
	-sid  |  --server-id	Server id of target. 	Overwrites $SCALR_SERVER_ID

Example:

	./scalr_tools.sh server-action 	--server https://scalr.example.com \
					--api-key APIK50123456789ABCDE \
					--api-secret 0123456789abcdef0123456789abcdef12345678 \
					--env-id 12345678-abcd-0000-xxxx-12345678 \
					resume abcd1234-0000-aaaa-1111-abcdef00
