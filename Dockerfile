FROM node:20.19.3@sha256:6a4de97365bb291992222c4f27cafc338773989712259e809632a873ff45a6ff

WORKDIR /workdir

COPY redirect-generator.js /
CMD ["node", "/redirect-generator.js"]
