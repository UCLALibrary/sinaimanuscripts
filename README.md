# Sinai Manuscripts Digital Library

The repo was forked form [Ursus](https://github.com/UCLALibrary/ursus)

---

#### Sinai Manuscripts

St. Catherine’s Monastery of the Sinai, in partnership with the Early Manuscripts Electronic Library (EMEL) and the UCLA Library, welcomes you to the Sinai Manuscripts Digital Library. Widely recognized as the world’s oldest continually operating library, the manuscript holdings of St. Catherine’s Monastery represent an unparalleled resource to study the history and literature of the Eastern Mediterranean from late antiquity until early modernity.

---

[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)
[![Coverage Status](https://coveralls.io/repos/github/UCLALibrary/sinaimanuscripts/badge.svg?branch=ci%2Fadd-coveralls)](https://coveralls.io/github/UCLALibrary/sinaimanuscripts?branch=ci%2Fadd-coveralls)
[![This project is using Percy.io for visual regression testing.](https://percy.io/static/images/percy-badge.svg)](https://percy.io/UCLA-Library-Software-Development/sinaimanuscripts)

---

## Development

This section gives basic instructions to get Sinai running locally. More extensive developer documentation is maintained [in the wiki](https://github.com/UCLALibrary/amalgamated-samvera/wiki).

### Install and run locally

Ursus is a [Blacklight](https://projectblacklight.org/) application and only needs Solr and Fedora.

Ursus can be locally run in two ways:

1. Running in standalone mode
1. Running in conjunction with local instance feedMe solr

---

## Standalone mode

The file `docker-compose-standalone.yml` includes a setup with a clone of the ursus-stage and sinai-stage solr indexes, so you do not need to run californica and manually ingest material (in fact, californica should #not# be running to avoid port conflicts.)

#### 1. Clone the repo from GitHub
```
cd sinaimanuscripts
```

#### 2. Set up the databases

```
docker-compose run sinai bundle exec rails db:setup
```

#### 3. Bring up the development environment

** Do this _after_ setting up the databases** - the startup scripts require the database to be ready so that they can set feature flags e.g. for the Sinai UI mode.

```
docker-compose up
```

#### Sinai should now be running locally at http://0.0.0.0:3004/

- [Sinai Manuscripts Digital Library](https://sinaimanuscripts.library.ucla.edu/) UI is enabled on [port 3004](http://localhost:3004)
  - **Note**: to view Sinai images, first visit the [production site](https://sinaimanuscripts.library.ucla.edu) and sign in/up to load the cookie from Production.

---

### Running linters and unit tests

#### Press these three buttons together when on a page to view in X-Ray SHIFT & COMMAND & X

Connect to a shell _inside_ the container with:

```
docker-compose run web bash
```

Then run the entire suite, except for the cypress integration test, with:

```
sh start-ci.sh
```

You can inspect the `start-ci.sh` script to see which linters and tests this invokes.

### Running the integration tests

First, you will need to install node.js and npm locally.

Then cd into the `e2e` directory and install the javascript dependencies:

```
cd e2e
npm install
```

Next, you can either open the cypress test runner GUI with:

```
npx cypress open
```

or run the tests in the command line:

```
npx cypress run
```

### Visual regression tests

Visual regression testing is done via [percy.io](https://percy.io/UCLA-Library-Software-Development/ursus). This runs only for pull requests on travis; it will not run locally.

---

## Running in conjunction with local instance of Californica

If the stand-alone version of Ursus is running, stop it with:

`docker-compose down`

#### 1. First, [install Californica](https://github.com/UCLALibrary/californica) and ingest some data;

make sure californica is running so ursus can point to its data.

#### 2.Clone the Ursus repo from GitHub and change directories into the Ursus repo:

```
git clone git@github.com:UCLALibrary/ursus.git
cd ursus
```

#### 4. Open a tab in your terminal

```
docker-compose -f docker-compose-with-californica.yml run web bundle exec rails db:setup
docker-compose -f docker-compose-with-californica.yml run sinai bundle exec rails db:setup
docker-compose -f docker-compose-with-californica.yml up
```

#### 5. Open a second tab in your terminal

This will connect to a shell _inside_ the container.  
This is where you will run the linters and unit tests

```
docker-compose -f docker-compose-with-californica.yml run web bash

```

#### 6. Open a third tab in your terminal

```
docker-compose -f docker-compose-with-californica.yml run sinai bash
```

#### 7. Open a fourth tab in your terminal for git commands

```
git ...
```
