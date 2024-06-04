FROM mcr.microsoft.com/devcontainers/base:jammy

RUN apt-get update && apt-get install -y curl git make gcc patch && apt-get clean

### change user to vscode
USER vscode
WORKDIR /home/vscode
ENV SHELL=/bin/bash  

### download plenvsetup  
RUN curl -sL https://is.gd/plenvsetup > plenvsetup && chmod +x plenvsetup  

### use plenvsetup on bash  
RUN bash plenvsetup  
  
### install perl-5.30.0 with plenv  
RUN ./.plenv/bin/plenv install 5.30.0  
RUN ./.plenv/bin/plenv global 5.30.0  
RUN ./.plenv/bin/plenv rehash 
RUN ./.plenv/bin/plenv install-cpanm

### install minilla
RUN ./.plenv/shims/cpanm Minilla