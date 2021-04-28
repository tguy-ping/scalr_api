# scalr_api
bash script for SCALR API

Usage: ./scalr_tools.sh <task> [flags] <action> <server-id>
Task:
  Use with action

	server-action
	request
	signature
Flags:
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
