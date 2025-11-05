FROM node:20.19.5@sha256:47dacd49500971c0fbe602323b2d04f6df40a933b123889636fc1f76bf69f58a

WORKDIR /workdir

COPY redirect-generator.js /
CMD ["node", "/redirect-generator.js"]
