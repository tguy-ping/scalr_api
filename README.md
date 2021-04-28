# scalr_api
bash script for SCALR API

Usage: ./scalr_tools.sh [task] [flags] [action] [server-id]

Task:
  Use with action

	server-action
	request
	signature
Flags (overrides environment variables):
  Use with any task

	-a    |  --server 	<your SCALR host>
	-k    |  --api-key	<Key with permissions for server/farm>
	-s    |  --api-secret	<Secret with permissions for server/farm>
	-e    |  --env-id	<environment id>
	-sid  |  --server-id	<server id of target>
Actions:

	status
	resume
	suspend
	sync
	terminate
Example:

	./scalr_tools.sh server-action -a https://scalr.example.com -k XXXXXXX -s xxxxxxxxxxxx --env-id 8 resume xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
	
Environment variables checked:

	SCALR_API_SERVER
	SCALR_API_KEY
	SCALR_API_SECRET
	SCALR_ENV_ID
	SCALR_SERVER_ID
