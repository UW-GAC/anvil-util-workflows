FROM uwgac/anvildatamodels:0.3.2

RUN cd /usr/local && \
    git clone https://github.com/UW-GAC/anvil-util-workflows.git
