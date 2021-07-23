.PHONY: frontend webapp payment gogo build　stop-services start-services truncate-logs bench kataribe

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

bench:
	cd bench && ./bin/bench_linux run --target=http://localhost

kataribe:
	sudo cat /var/log/nginx/access.log | ./kataribe
