server {
    listen 8778;
    location / {
      uwsgi_pass 127.0.0.1:8080;
      uwsgi_param SCRIPT_NAME '';
      include uwsgi_params;
    }
}
