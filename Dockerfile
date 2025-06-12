FROM node:22.16.0@sha256:71bcbb3b215b3fa84b5b167585675072f4c270855e37a599803f1a58141a0716

WORKDIR /workdir

COPY redirect-generator.js /
CMD ["node", "/redirect-generator.js"]
