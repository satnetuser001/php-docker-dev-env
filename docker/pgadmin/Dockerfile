# base docker image
FROM dpage/pgadmin4:latest

# copy pgpass file from secrets context and set correct permissions
COPY --from=secrets pgadmin_pgpass.txt /pgpass
RUN chmod 600 /pgpass && chown pgadmin:pgadmin /pgpass

ENTRYPOINT ["/entrypoint.sh"]
