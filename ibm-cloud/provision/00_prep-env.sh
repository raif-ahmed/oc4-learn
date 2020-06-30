#!/bin/bash

. params

if command -v $IBMC > /dev/null ; then
  echo "Installing plugins.. " 
  ${IBMC} plugin install cloud-object-storage -q -f
  ${IBMC} plugin install container-registry -q -f
  ${IBMC} plugin install container-service -q -f
  ${IBMC} plugin install cloud-functions -q -f
else
  echo "${IBMC} does not exist"
fi
