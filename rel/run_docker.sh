docker run -it -d --rm \
-e DB_URL=${DB_URL} \
-e RELEASE_COOKIE=secret-cookie \
-e SECRET_KEY_BASE=${SECRET_KEY_BASE} \
-e SERVICE_NAME=geo-racer \
-e APP_HOST=localhost \
-e PORT=4000 \
--network geo-racer-net --publish 4000:4000 geo_racer:latest