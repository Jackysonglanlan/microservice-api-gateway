# nginx-remote-automator
nginx automator via npm script

## PERSONAL USE

## Usage

 npm script | description 
------------|-------------
deploy-config | deploy *all* the config files in `vhost` dir to the specified remote location
remote-reload | fire `nginx -s reload` on remote server

`deploy-config` will use linux timestamp to implement version control.
