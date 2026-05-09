# base docker image
FROM dpage/pgadmin4:latest

# copy pgpass file from secrets directory and set correct permissions
COPY pgpass /pgpass
RUN chmod 600 /pgpass && chown pgadmin:pgadmin /pgpass

ENTRYPOINT ["/entrypoint.sh"]
