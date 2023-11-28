# Sample bokeh application scheduled with docker compose

Note: the application sample is taken from
https://docs.bokeh.org/en/latest/docs/user_guide/server/app.html

    cd other_stuff/bokeh_sample
    docker-compose -f docker-compose.yml up -d --build
    curl -v http://localhost:8080/bokeh_sample
    docker-compose -f docker-compose.yml logs -f
    docker-compose -f docker-compose.yml down -v --remove-orphans
