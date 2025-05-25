FROM node:20.19.2@sha256:7c4cd7c6935554b79c6fffb88e7bde3db0ce25b45d4c634d1fb0f1a6e7f5b782

WORKDIR /workdir

COPY redirect-generator.js /
CMD ["node", "/redirect-generator.js"]
