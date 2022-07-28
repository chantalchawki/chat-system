## Running the code:

To run the migration (for the first time only):
```bash
docker-compose exec server bundle exec rake db:migrate 
```

To run the docker-compose.yml file:
```bash
docker-compose up -d
```

## Postman Collection:
[postman-collection](./documentation/chat-system.postman_collection.json)