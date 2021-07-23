.PHONY: frontend webapp payment gogo build　stop-services start-services kenji truncate-logs bench kataribe

all: frontend webapp payment bench

frontend:
	cd webapp/frontend && make
	cd webapp/frontend/dist && tar zcvf ../../../ansible/files/frontend.tar.gz .

webapp:
	tar zcvf ansible/files/webapp.tar.gz \
	--exclude webapp/frontend \
	webapp

payment:
	cd blackbox/payment && make && cp bin/payment_linux ../../ansible/roles/benchmark/files/payment

gogo: stop-services build kenji minako truncate-logs start-services bench

build:
	make -C webapp/go isutrain

stop-services:
	sudo systemctl stop nginx
	sudo systemctl stop isutrain-go.service
	sudo systemctl stop mysql

start-services:
	sudo systemctl start mysql
	sleep 5
	sudo systemctl start isutrain-go.service
	sudo systemctl start nginx

truncate-logs:
	sudo truncate --size 0 /var/log/nginx/access.log
	sudo truncate --size 0 /var/log/nginx/error.log
	sudo truncate --size 0 /var/log/mysql/mysql-slow.log
	sudo truncate --size 0 /var/log/mysql/error.log

bench:
	@curl -X POST http://localhost:5000/initialize > /dev/null
	ssh isucon@3.114.9.128 "cd /home/isucon/isutrain/bench && ./bin/bench_linux run --payment=http://35.75.15.159:5000   --target=http://35.75.15.159"
kataribe:
	sudo cat /var/log/nginx/access.log | ./kataribe

kenji: TS=$(shell date "+%Y%m%d_%H%M%S")
kenji: 
	mkdir /home/isucon/logs/$(TS)
	sudo  cp -p /var/log/nginx/access.log  /home/isucon/logs/$(TS)/access.log
	sudo  cp -p /var/log/mysql/mysql-slow.log  /home/isucon/logs/$(TS)/mysql-slow.log
	sudo chmod -R 777 /home/isucon/logs/*
minako:
	scp -C kataribe.toml ubuntu@35.74.231.100:~/
	rsync -av -e ssh /home/isucon/logs ubuntu@35.74.231.100:/home/ubuntu  
satuki:
	ssh ubuntu@35.74.231.100 "sh push_github.sh"
couple: kenji minako satuki

