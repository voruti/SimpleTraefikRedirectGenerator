FROM node:20.19.2@sha256:ba077fe891ce516b24bdbbd66d27d1e8e8c5a6e6b31ec7e7e559b45c3fca0643

WORKDIR /workdir

COPY redirect-generator.js /
CMD ["node", "/redirect-generator.js"]
