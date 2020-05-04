# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM alpine:3.11.6 as builder
RUN apk add --no-cache curl make gcc g++ binutils-gold python linux-headers paxctl libgcc libstdc++ git vim tar gzip wget
ENV NODE_VERSION=10.20.1
ENV NEXE_VERSION=3.3.2
RUN mkdir /${NODE_VERSION} && curl -sSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz | tar -zx --strip-components=1 -C /${NODE_VERSION}

WORKDIR /${NODE_VERSION}

# Add the .cc and .js for deasync
COPY etc/ /${NODE_VERSION}

# configure
RUN ./configure --prefix=/usr --fully-static

# Include the node-gyp module converted to 'builtin' module
RUN \
   # Include .js in the libraries
   sed -i -e "s|    \\'library_files\\': \\[|    \\'library_files\\': \\[\n      \\'lib/deasync.js\\',|" node.gyp && \
   # Include the .cc in src list
   sed -i -e "s|        'src/uv.cc',|        'src/uv.cc',\n        'src/deasync.cc',|" node.gyp && \
   # Include the deasync module in modules list
   sed -i -e "s|    V(messaging)                                                              \\\|    V(messaging)                                                              \\\ \n    V(deasync)                                                                \\\|" src/node_internals.h

# Compile
RUN make -j 8 -&& make install && paxctl -cm /usr/bin/node

# install nexe
#RUN npm install -g nexe@${NEXE_VERSION}

# remove node binary
#RUN rm out/Release/node

# Change back to root folder
#WORKDIR /

## Add dummy sample to create the all-in-one ready-to-use package
#RUN echo "console.log('hello world')" >> index.js

# Build pre-asssembly of nodejs by using nexe and reusing our patched nodejs folder
#RUN nexe --build --no-mangle --temp / -c="--fully-static" -m="-j8" --target ${NODE_VERSION} -o pre-assembly-nodejs-static

# ok now make the image smaller with only the binary
#FROM alpine:3.11.6 as runtime
#COPY --from=builder /pre-assembly-nodejs-static /pre-assembly-nodejs-static
