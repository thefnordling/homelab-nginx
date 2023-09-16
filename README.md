# homelab-nginx
this is the setup for the reverse proxy i use in my homelab

bits to highlight:

1) the root and intermediate CAs are downloaded from vault and included in the image from the dockerfile (nevermind the lack of https on this, this is a homelab and i just haven't gotten to that service yet)
2) a bash script runs on a loop in the background, re-issuing the leaf/server-hosting cert every 30 days and reloading nginx when the cert canges