INSERT INTO onm.cfg_host_types (descr) VALUES ("Appliance") ON DUPLICATE KEY UPDATE descr="Appliance";
INSERT INTO onm.cfg_host_types (descr) VALUES ("Servidor") ON DUPLICATE KEY UPDATE descr="Servidor";
INSERT INTO onm.cfg_host_types (descr) VALUES ("Router") ON DUPLICATE KEY UPDATE descr="Router";
INSERT INTO onm.cfg_views_types (name) VALUES ("Servicios") ON DUPLICATE KEY UPDATE name="Servicios";
INSERT INTO onm.cfg_views_types (name) VALUES ("Infraestructura") ON DUPLICATE KEY UPDATE name="Infraestructura";
