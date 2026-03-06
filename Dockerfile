FROM uwgac/anvildatamodels:0.8.1

RUN cd /usr/local && \
    git clone https://github.com/UW-GAC/anvil-util-workflows.git
