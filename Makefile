OUTLINE_VERSION = latest

up:
	docker compose up -d redis postgres
	yarn install-local-ssl
	yarn install --pure-lockfile
	cp .env.sample .env
	@sed -i "s/^SECRET_KEY=.*/SECRET_KEY=$$(openssl rand -hex 32)/" .env;
	@sed -i "s/^UTILS_SECRET=.*/UTILS_SECRET=$$(openssl rand -hex 32)/" .env;
	@sed -i 's|^URL=.*|URL=http://127.0.0.1|' .env;

build:
	yarn build
	docker build  --network=host -t outline/outline:${OUTLINE_VERSION} .

test:
	docker compose up -d redis postgres
	NODE_ENV=test yarn sequelize db:drop
	NODE_ENV=test yarn sequelize db:create
	NODE_ENV=test yarn sequelize db:migrate
	yarn test

watch:
	docker compose up -d redis postgres
	NODE_ENV=test yarn sequelize db:drop
	NODE_ENV=test yarn sequelize db:create
	NODE_ENV=test yarn sequelize db:migrate
	yarn dev:watch

destroy:
	docker compose stop
	docker compose rm -f

clean:
	yarn clean

.PHONY: up build destroy test watch clean # let's go to reserve rules names
