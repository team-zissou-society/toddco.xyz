# Stage 1: Build the static site
FROM hugomods/hugo:std-ci-non-root-0.147.0 AS builder
 

WORKDIR /tmp/site


COPY --chown=hugo:hugo . .
# Preload Hugo modules
RUN hugo mod get
RUN hugo mod vendor

# Help our sanity check later, make sure there is no public/ folder
RUN rm -rf public/
RUN hugo --minify

# Sanity check: Did Hugo actually build something?
RUN if [ ! -d public ] || [ ! -f public/index.html ]; then echo "ERROR: Hugo build failed — public/ missing or index.html missing!" && exit 1; fi


# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy the custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf
# Copy the built site from the builder stage
COPY --from=builder /tmp/site/public/ /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]