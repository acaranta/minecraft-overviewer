# To use this Docker image, make sure you set up the mounts properly.
#
# The Minecraft server files are expected at
#     /home/minecraft/server
#
# The Minecraft-Overviewer render will be output at
#     /home/minecraft/render

FROM ubuntu:20.04

LABEL MAINTAINER='Mark Ide Jr (https://www.mide.io)'

#Default Loop Wait Time
ENV WAIT_MINUTES 7200

# Default to do both render Map + POI
ENV RENDER_MAP true
ENV RENDER_POI true

# Only render signs including this string, leave blank to render all signs
ENV RENDER_SIGNS_FILTER "-- RENDER --"

# Hide the filter string from the render
ENV RENDER_SIGNS_HIDE_FILTER "false"

# What to join the lines of the sign with when rendering POI
ENV RENDER_SIGNS_JOINER "<br />"

ENV CONFIG_LOCATION /home/minecraft/config.py

# Build Overviewer freom source
RUN apt-get update                                                      && \
    apt-get install -y                                                     \
        python3                                                            \
        build-essential                                                    \
        python3-pip                                                        \
        python3-pillow                                                     \
        python3-numpy                                                      \
        wget                                                               \
        git                                                             && \
    mkdir /tmp/buildover                                                && \
    cd /tmp/buildover                                                   && \
    git clone https://github.com/overviewer/Minecraft-Overviewer.git .  && \
    python3 setup.py build                                              && \
    apt-get purge -y                                                       \
        build-essential                                                    \
        python3-pip                                                        \
        git                                                             && \
    apt-get autoremove -y                                               && \
    apt-get clean                                                       && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd minecraft -g 1000 && \
    useradd -m minecraft -u 1000 -g 1000 && \
    mkdir -p /home/minecraft/render /home/minecraft/server

COPY config/config.py /home/minecraft/config.py
COPY entrypoint.sh /home/minecraft/entrypoint.sh
COPY download_url.py /home/minecraft/download_url.py

RUN chown minecraft:minecraft -R /home/minecraft/

WORKDIR /home/minecraft/

USER minecraft

CMD ["bash", "/home/minecraft/entrypoint.sh"]
