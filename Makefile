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

gogo: stop-services build kenji truncate-logs start-services bench

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
	cd bench && ./bin/bench_linux run --target=http://localhost

kataribe:
	sudo cat /var/log/nginx/access.log | ./kataribe

kenji:
	sudo  cp -p /var/log/nginx/access.log  /home/isucon/logs/nginx/access.`date "+%Y%m%d_%H%M%S"`.log
	sudo  cp -p /var/log/mysql/mysql-slow.log  /home/isucon/logs/mysql/mysql-slow.`date "+%Y%m%d_%H%M%S"`.log 
	sudo chmod -R 777 /home/isucon/logs/*
