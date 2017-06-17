#!/bin/sh -xe

/opt/nova/bin/nova-manage api_db sync

/opt/nova/bin/nova-manage cell_v2 list_cells | grep cell0 || /opt/nova/bin/nova-manage cell_v2 map_cell0
/opt/nova/bin/nova-manage cell_v2 list_cells | grep cell1 || /opt/nova/bin/nova-manage cell_v2 create_cell --name=cell1 --verbose
/opt/nova/bin/nova-manage db sync