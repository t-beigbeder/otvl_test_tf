cmd_dir=`dirname $0`
cmd_name=`basename $0`
if [ "`echo $cmd_dir | cut -c1`" != "/" ] ; then
    cmd_dir="`pwd`/$cmd_dir"
fi

root_dir="`echo $cmd_dir | sed -e s=/app_sample==`"

log() {
  TS=`date +%Y/%m/%d" "%H:%M:%S",000"`
  echo "$TS | $1 | $cmd_name: $2" | tee -a /tmp/app_sample_install.log
}

error() {
  log ERROR "$1"
}

warn() {
  log WARNING "$1"
}

info() {
  log INFO "$1"
}

run_command() {
    info "run command \"$*\""
    "$@" || (error "while running command \"$*\"" && return 1)
}

mount_efs() {
  fsid=`aws --region $region efs describe-file-systems |grep FileSystemId|cut -d'"' -f4`
  run_command aws --region $region efs describe-file-systems && \
  run_command mkdir /srv/efs && \
  run_command mount -t efs -o tls -o iam $fsid /srv/efs && \
  true
}

install_nginx() {
    cat > /etc/nginx/conf.d/nginx_ssl.conf <<EOF2
    server {
      listen 443 ssl http2;
      listen [::]:443 ssl http2;
      server_name _;
      root /usr/share/nginx/html;
      ssl_certificate "/etc/ssl/certs/nginx-selfsigned.crt";
      ssl_certificate_key "/etc/ssl/private/nginx-selfsigned.key";
      ssl_session_cache shared:SSL:1m;
      ssl_session_timeout 10m;
      ssl_ciphers HIGH:!aNULL:!MD5;
      ssl_prefer_server_ciphers on;
      error_page 404 /404.html;
      location = /40x.html {
      }
      error_page 500 502 503 504 /50x.html;
      location = /50x.html {
      }
    }
EOF2

    run_command ls -l /etc/nginx/conf.d/nginx_ssl.conf && \
    run_command mkdir /etc/ssl/private && \
    run_command openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=EU/ST=FR/L=AWS/O=Nginx/OU=root/CN=`hostname -i`/emailAddress=root@localhost" && \
    systemctl enable nginx && \
    systemctl start nginx && \
    true
}

install_docker() {
  run_command amazon-linux-extras install docker && \
  run_command usermod -a -G docker aws_install && \
  run_command systemctl enable docker && \
  run_command systemctl start docker && \
  true
}

st=0
region=$1
export region
info "starting"
true && \
  run_command pwd && \
  run_command id && \
  run_command mount_efs && \
  run_command install_nginx && \
  true || (info failed && exit 1)
st=$?
info "ended"
exit $st
