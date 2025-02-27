start:
	docker-compose up -d --build

healthcheck:
	docker-compose run --rm healthcheck

down:
	docker-compose down

install: start healthcheck

configure:
	docker-compose -f docker-compose.yml -f wp-auto-config.yml run --rm wp-auto-config

autoinstall: start
	docker-compose -f docker-compose.yml -f wp-auto-config.yml run --rm wp-auto-config

clean: down
	@echo "💥 Removing related folders/files..."
	@rm -rf  mysql/* wordpress/*

reset: clean

compress:
	@sudo rm -f mysql.tar.xz
	@sudo tar cvfz mysql.tar.xz mysql

extract:
	@sudo rm -rf mysql
	@sudo tar -xvzf mysql.tar.xz
fixpermission:
	docker compose exec wordpress sh -c "chown www-data:www-data  -R * "
	docker compose exec wordpress sh -c "find . -type d -exec chmod 755 {} \;  "
	docker compose exec wordpress sh -c "find . -type f -exec chmod 644 {} \;"
	docker compose exec wordpress sh -c "chown www-data:www-data wp-content"
