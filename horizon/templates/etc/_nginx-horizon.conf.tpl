server {
    listen 8000;
    location / {
      uwsgi_pass 127.0.0.1:8001;
      uwsgi_param SCRIPT_NAME '';
      include uwsgi_params;
    }

    location /static {
      alias /opt/horizon/share/horizon/static;
    }
}
