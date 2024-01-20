FROM uwgac/anvildatamodels:0.5.0

RUN cd /usr/local && \
    git clone https://github.com/UW-GAC/anvil-util-workflows.git
