FROM node:22.17.0@sha256:379057ef411aeee92a4a58202ccde8cbe6a48a9d48e451cfc6df63a91f70a441

WORKDIR /workdir

COPY redirect-generator.js /
CMD ["node", "/redirect-generator.js"]
