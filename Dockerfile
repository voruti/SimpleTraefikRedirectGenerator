FROM node:20.19.3@sha256:2c3f34d2d28e4c13b26f7244c653527d15544626e85b1a21fb67a95ba4df9a01

WORKDIR /workdir

COPY redirect-generator.js /
CMD ["node", "/redirect-generator.js"]
