FROM node:20

WORKDIR /workdir

COPY redirect-generator.js /
CMD ["node", "/redirect-generator.js"]
