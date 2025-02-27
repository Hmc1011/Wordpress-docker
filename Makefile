up:
	docker compose up -d
start:
	docker compose up -d --build

healthcheck:
	docker compose run --rm healthcheck

down:
	docker compose down

install: start healthcheck

configure:
	docker compose -f docker compose.yml -f wp-auto-config.yml run --rm wp-auto-config

autoinstall: start
	docker compose -f docker compose.yml -f wp-auto-config.yml run --rm wp-auto-config

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


import-db:
	@echo "Make sure you have db.sql in workspace..."
	@echo "🚀 Starting database import process..."
	# Ensure mysql service is running
	@docker compose up -d mysql > /dev/null 2>&1
	# Drop and recreate the database
	@docker compose exec -T mysql sh -c "mysql -u root -p$${MYSQL_ROOT_PASSWORD:-password} -e 'DROP DATABASE IF EXISTS $${COMPOSE_PROJECT_NAME:-wordpress}; CREATE DATABASE $${COMPOSE_PROJECT_NAME:-wordpress};'"
	# Import db.sql from the host using a pipe
	@cat ./db.sql | docker compose exec -T mysql sh -c "mysql -u root -p$${MYSQL_ROOT_PASSWORD:-password} $${COMPOSE_PROJECT_NAME:-wordpress}"
	@echo "✅ Database import completed!"

export-db:
	@echo "🚀 Starting database export process..."
	# Đảm bảo container mysql đang chạy
	@docker compose up -d mysql
	# Xuất database ra file db.sql
	@docker compose exec -T mysql mysqldump -u "$${DATABASE_USER:-root}" -p"$${DATABASE_PASSWORD:-password}" "$${COMPOSE_PROJECT_NAME:-wordpress}" > ./export.sql
	# Nén file db.sql thành db.sql.zip
	@zip -r ./export.sql.zip ./export.sql
	@echo "✅ Database export completed! File saved as export.sql.zip and export.sql"