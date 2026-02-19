FROM uclalibrary/solr-ursus:8

# Set up a home directory for uv to use
USER root
RUN mkdir --parents /home/solr
RUN chown solr:solr /home/solr
USER solr

# install feed_ursus
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN uv tool install --python 3.13 feed_ursus
ENV PATH=/home/solr/.local/bin:$PATH


# get data
COPY sinaiportal_data /data
COPY load_data.sh /data
RUN bash /data/load_data.sh