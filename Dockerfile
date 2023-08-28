FROM ghost:5.60-alpine as ghos3
RUN apk add g++ make python3
RUN su-exec node yarn add ghos3

FROM ghost:5.60-alpine
COPY --chown=node:node --from=ghos3 $GHOST_INSTALL/node_modules $GHOST_INSTALL/node_modules
COPY --chown=node:node --from=ghos3 $GHOST_INSTALL/content/adapters/storage/s3 $GHOST_INSTALL/content/adapters/storage/s3
# copy again to content.orig folders for preseeding empty volumes
COPY --chown=node:node --from=ghos3 $GHOST_INSTALL/content/adapters/storage/s3 $GHOST_INSTALL/content.orig/adapters/storage/s3

# Define the ARGs and ENVs
ARG AWS_ACCESS_KEY_ID
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ARG GHOST_STORAGE_ADAPTER_S3_PATH_BUCKET
ENV GHOST_STORAGE_ADAPTER_S3_PATH_BUCKET=$GHOST_STORAGE_ADAPTER_S3_PATH_BUCKET
ARG GHOST_STORAGE_ADAPTER_S3_ASSET_HOST
ENV GHOST_STORAGE_ADAPTER_S3_ASSET_HOST=$GHOST_STORAGE_ADAPTER_S3_ASSET_HOST
ARG GHOST_STORAGE_ADAPTER_S3_ENDPOINT
ENV GHOST_STORAGE_ADAPTER_S3_ENDPOINT=$GHOST_STORAGE_ADAPTER_S3_ENDPOINT
ARG GHOST_STORAGE_ADAPTER_S3_PATH_PREFIX
ENV GHOST_STORAGE_ADAPTER_S3_PATH_PREFIX=$GHOST_STORAGE_ADAPTER_S3_PATH_PREFIX

# Here, we use the Ghost CLI to set some pre-defined values.
RUN set -ex; \
    su-exec node ghost config storage.active s3; \
    su-exec node ghost config storage.s3.accessKeyId $AWS_ACCESS_KEY_ID; \
    su-exec node ghost config storage.s3.secretAccessKey $AWS_SECRET_ACCESS_KEY; \
    su-exec node ghost config storage.s3.bucket $GHOST_STORAGE_ADAPTER_S3_PATH_BUCKET; \
    su-exec node ghost config storage.s3.assetHost $GHOST_STORAGE_ADAPTER_S3_ASSET_HOST; \
    su-exec node ghost config storage.s3.endpoint $GHOST_STORAGE_ADAPTER_S3_ENDPOINT; \
    su-exec node ghost config storage.s3.pathPrefix $GHOST_STORAGE_ADAPTER_S3_PATH_PREFIX; \
    su-exec node ghost config storage.s3.forcePathStyle true; \