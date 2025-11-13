FROM node:24.11.1-slim@sha256:f752e4821362614eab35016f01dea3af61d2f59d0445381c25683e4331520a7b

WORKDIR /workdir

COPY redirect-generator.js /
CMD ["node", "/redirect-generator.js"]
