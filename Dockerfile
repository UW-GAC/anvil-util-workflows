FROM uwgac/anvildatamodels:0.4.6

RUN cd /usr/local && \
    git clone https://github.com/UW-GAC/anvil-util-workflows.git
