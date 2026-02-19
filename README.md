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

Data is maintained at https://github.com/UCLALibrary/sinaiportal_data, which is included as a git submodule.
