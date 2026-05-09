# base docker image
FROM dpage/pgadmin4:latest

# switch to root to set file permissions
USER root

# copy pgpass file from secrets context and set correct permissions
COPY --from=secrets pgadmin_pgpass.txt /pgpass
RUN chmod 600 /pgpass && chown pgadmin:pgadmin /pgpass

# switch back to pgadmin user
USER pgadmin

ENTRYPOINT ["/entrypoint.sh"]
