FROM ghost:5.60-alpine as cloudinary
RUN apk add g++ make python3
RUN su-exec node yarn add ghost-storage-cloudinary

FROM ghost:5.60-alpine
ARG MAILGUN_USER
ARG MAILGUN_PASS
ENV MAILGUN_USER=$MAILGUN_USER
ENV MAILGUN_PASS=$MAILGUN_PASS
COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/node_modules $GHOST_INSTALL/node_modules
COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/node_modules/ghost-storage-cloudinary $GHOST_INSTALL/content/adapters/storage/ghost-storage-cloudinary
# copy again to content.orig folders for preseeding empty volumes
COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/node_modules/ghost-storage-cloudinary $GHOST_INSTALL/content.orig/adapters/storage/ghost-storage-cloudinary
# Here, we use the Ghost CLI to set some pre-defined values.
# "mail": {
# "transport": "SMTP",
# "options": {
# "service": "Mailgun",
# "host": "smtp.mailgun.org",
# "port": 465,
# "secure": true,
# "auth": {
# "user": "postmaster@example.mailgun.org",
# "pass": "1234567890"
# }
# }
# },

RUN set -ex; \
    su-exec node ghost config storage.active ghost-storage-cloudinary; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.use_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.unique_filename false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.overwrite false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.quality auto; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.secure true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.cdn_subdomain true; \
    su-exec node ghost config mail.transport SMTP; \
    su-exec node ghost config mail.options.service Mailgun; \
    su-exec node ghost config mail.options.host smtp.mailgun.org; \
    su-exec node ghost config mail.options.port 465; \
    su-exec node ghost config mail.options.secure true; \
    su-exec node ghost config mail.options.auth.user $MAILGUN_USER; \
    su-exec node ghost config mail.options.auth.pass $MAILGUN_PASS; \
    su-exec node ghost config mail.from 'no-reply@wkmn.email' ; \
    su-exec node ghost config mail.replyTo 'support@wkmn.email' ;
