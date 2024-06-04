FROM mcr.microsoft.com/devcontainers/base:jammy

RUN apt-get update && apt-get install -y curl git make gcc patch && apt-get clean
  
### download plenvsetup  
RUN curl -sL https://is.gd/plenvsetup > plenvsetup && chmod +x plenvsetup  
  
### use plenvsetup on bash  
ENV SHELL=/bin/bash  
RUN bash plenvsetup  
  
### install perl-5.30.0 with plenv  
WORKDIR /root
RUN .plenv/bin/plenv install 5.30.0  
RUN .plenv/bin/plenv global 5.30.0  
RUN .plenv/bin/plenv rehash 