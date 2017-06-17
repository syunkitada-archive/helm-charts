server {
    listen 5000;
    location / {
      uwsgi_pass 127.0.0.1:6000;
      uwsgi_param SCRIPT_NAME '';
      include uwsgi_params;
    }
}

server {
    listen 35357;
    location / {
      uwsgi_pass 127.0.0.1:36357;
      uwsgi_param SCRIPT_NAME '';
      include uwsgi_params;
    }
}
