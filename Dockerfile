FROM ghost:5.60-alpine as ghos3
RUN apk add g++ make python3
RUN su-exec node yarn add ghos3
# create a new folder for the adapter
RUN mkdir -p $GHOST_INSTALL/content/adapters/storage
# cp -r ./node_modules/ghos3/* ./content/adapters/storage/s3
RUN cp -r $GHOST_INSTALL/node_modules/ghos3/* $GHOST_INSTALL/content/adapters/storage/s3

FROM ghost:5.60-alpine
COPY --chown=node:node --from=ghos3 $GHOST_INSTALL/node_modules $GHOST_INSTALL/node_modules
COPY --chown=node:node --from=ghos3 $GHOST_INSTALL/content/adapters/storage/s3 $GHOST_INSTALL/content/adapters/storage/s3
# copy again to content.orig folders for preseeding empty volumes
COPY --chown=node:node --from=ghos3 $GHOST_INSTALL/content/adapters/storage/s3 $GHOST_INSTALL/content.orig/adapters/storage/s3

# Here, we use the Ghost CLI to set some pre-defined values.
RUN set -ex; \
    su-exec node ghost config storage.active s3; \
    su-exec node ghost config storage.s3.forcePathStyle true; \