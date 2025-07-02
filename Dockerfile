FROM node:20.19.3@sha256:68d27797e56fa39248e0372b1017075c11f3a81b5baa2daa7d23af4b3f8f6918

WORKDIR /workdir

COPY redirect-generator.js /
CMD ["node", "/redirect-generator.js"]
