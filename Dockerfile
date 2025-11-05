FROM node:22.21.1@sha256:dcf06103a9d4087e3244a51697adbbb85331dcb7161dbe994ca1cd07dd32e2a5

WORKDIR /workdir

COPY redirect-generator.js /
CMD ["node", "/redirect-generator.js"]
