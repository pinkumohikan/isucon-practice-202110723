.PHONY: frontend webapp payment bench stop-services start-services truncate-logs gogo build kataribe

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

gogo: stop-services build truncate-logs start-services

build:
	

stop-services:
	sudo systemctl stop nginx
	sudo systemctl stop isutrain.go.service
	sudo systemctl stop mysql

start-services:
	sudo systemctl start mysql
	sleep 5
	sudo systemctl start isutrain.go.service
	sudo systemctl start nginx

truncate-logs:
	sudo truncate --size 0 /var/log/nginx/access.log
	sudo truncate --size 0 /var/log/nginx/error.log

bench:
	cd bench && make && cp -av bin/bench_linux ../ansible/roles/benchmark/files/bench && cp -av bin/benchworker_linux ../ansible/roles/benchmark/files/benchworker

kataribe:
	sudo cat /var/log/nginx/access.log | ./kataribe