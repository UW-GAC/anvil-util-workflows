FROM uwgac/anvildatamodels:0.2.1

RUN cd /usr/local && \
    git clone https://github.com/UW-GAC/anvil-util-workflows.git
