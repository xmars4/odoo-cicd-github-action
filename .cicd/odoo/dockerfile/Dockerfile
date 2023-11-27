FROM odoo:16

# Use root user instead of odoo user to handle logging easier
USER root

COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

COPY ./requirements.txt /etc/odoo/requirements.txt
RUN pip3 install -r /etc/odoo/requirements.txt

RUN mkdir -p /mnt/et-addons /mnt/custom-addons \
    && chown -R odoo /mnt/et-addons  /mnt/custom-addons \
    && chown odoo /etc/odoo/odoo.conf 

VOLUME ["/mnt/et-addons"]
VOLUME ["/mnt/custom-addons"]
