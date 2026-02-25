#!/bin/bash

set -e


SOLR_URL=${COLLECTION_NAME:-http://localhost:8983/solr/ursus}
DATA_DIR=${DATA_DIR:-/data}


echo "Starting Solr in the background...!!!"
# Start Solr in the background, the control script handles the background process
bin/solr start

# Wait a few seconds for Solr to fully start up
sleep 3

echo "Indexing data..."
sinai load $DATA_DIR

echo "Indexing complete. Stopping Solr..."
# Stop the Solr instance
bin/solr stop

echo "Solr stopped."
