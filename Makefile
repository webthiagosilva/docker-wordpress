bash:
	docker exec -it wordpress bash

bash-root:
	docker exec -it -u0 wordpress bash
