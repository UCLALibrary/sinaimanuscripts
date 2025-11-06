# Sinai Manuscripts Digital Library

Frontend web app for the [Sinai Manuscripts Digital Library](https://sinaimanuscripts.library.ucla.edu)

The README is incomplete

---


## Development


### Data

Data is maintained at https://github.com/UCLALibrary/sinaiportal_data and loaded with https://github.com/UCLALibrary/feed_ursus. The loaddata docker container automates this for the development environment.

The loaddata container should run and populate solr every time you run `docker-compose up`. To fetch new data from the sinaiportal_data repo, you'll need to rebuild the container:
```docker-compose run --build loaddata```


