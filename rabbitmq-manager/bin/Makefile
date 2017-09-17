dev:
	easy_install pip
	pip install virtualenv
	virtualenv /opt/rabbitmq-manager
	/opt/rabbitmq-manager/bin/pip install -r requirements.txt
	mkdir -p /mnt/rabbitmq/etc/
	cp ../values.yaml /mnt/rabbitmq/etc/
