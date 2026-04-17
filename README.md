# Sinai Manuscripts Digital Library

Frontend web app for the [Sinai Manuscripts Digital Library](https://sinaimanuscripts.library.ucla.edu)

The README is incomplete

---

## Development

```
git submodule sync
docker-compose run sinai bundle exec rails db:setup
docker-compose up
```

### Data

Data is maintained at https://github.com/UCLALibrary/sinaiportal_data, which is included as a git submodule. It is loaded with the `sinai load` command of [feed_ursus](https://github.com/uclalibrary/feed_ursus), which runs automatically in a container on `docker-compose up`. It can be re-run at any time with `docker-compose run loader`.
