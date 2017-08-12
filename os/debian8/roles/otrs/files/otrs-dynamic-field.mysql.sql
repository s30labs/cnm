-- --
-- -- Table structure for table `dynamic_field`
-- --
-- 
-- DROP TABLE IF EXISTS `dynamic_field`;
-- /*!40101 SET @saved_cs_client     = @@character_set_client */;
-- /*!40101 SET character_set_client = utf8 */;
-- CREATE TABLE `dynamic_field` (
--   `id` int(11) NOT NULL AUTO_INCREMENT,
--   `name` varchar(200) NOT NULL,
--   `label` varchar(200) NOT NULL,
--   `field_order` int(11) NOT NULL,
--   `field_type` varchar(200) NOT NULL,
--   `object_type` varchar(200) NOT NULL,
--   `config` longblob,
--   `valid_id` smallint(6) NOT NULL,
--   `create_time` datetime NOT NULL,
--   `create_by` int(11) NOT NULL,
--   `change_time` datetime NOT NULL,
--   `change_by` int(11) NOT NULL,
--   PRIMARY KEY (`id`),
--   UNIQUE KEY `dynamic_field_name` (`name`),
--   KEY `FK_dynamic_field_create_by_id` (`create_by`),
--   KEY `FK_dynamic_field_change_by_id` (`change_by`),
--   KEY `FK_dynamic_field_valid_id_id` (`valid_id`)
-- ) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
-- /*!40101 SET character_set_client = @saved_cs_client */;
-- 
-- 
-- --
-- -- Dumping data for table `dynamic_field`
-- --
-- 
-- LOCK TABLES `dynamic_field` WRITE;
-- /*!40000 ALTER TABLE `dynamic_field` DISABLE KEYS */;
-- INSERT INTO `dynamic_field` VALUES (1,'category','Category',1,'Text','Ticket','---\nDefaultValue: \'\'\nLink: \'\'\n',1,'2013-12-09 14:22:12',1,'2013-12-09 20:25:08',1),(2,'type','Type',2,'Dropdown','Ticket','---\nDefaultValue: 1\nLink: \'\'\nPossibleNone: 0\nPossibleValues:\n  1: Incident\n  2: Event\nTranslatableValues: 0\n',1,'2013-12-09 14:23:10',1,'2013-12-09 20:25:01',1),(3,'element','Element',3,'Text','Ticket','---\nDefaultValue: \'\'\nLink: \'\'\n',1,'2013-12-09 14:23:29',1,'2013-12-09 20:25:14',1),(5,'global','Global',4,'Dropdown','Ticket','---\nDefaultValue: 2\nLink: \'\'\nPossibleNone: 0\nPossibleValues:\n  1: Yes\n  2: No\nTranslatableValues: 0\n',1,'2013-12-09 20:23:13',1,'2013-12-09 21:41:10',1);
-- /*!40000 ALTER TABLE `dynamic_field` ENABLE KEYS */;
-- UNLOCK TABLES;
-- 


--
-- Table structure for table `dynamic_field`
--

DROP TABLE IF EXISTS `dynamic_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dynamic_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `internal_field` smallint(6) NOT NULL DEFAULT '0',
  `name` varchar(200) NOT NULL,
  `label` varchar(200) NOT NULL,
  `field_order` int(11) NOT NULL,
  `field_type` varchar(200) NOT NULL,
  `object_type` varchar(200) NOT NULL,
  `config` longblob,
  `valid_id` smallint(6) NOT NULL,
  `create_time` datetime NOT NULL,
  `create_by` int(11) NOT NULL,
  `change_time` datetime NOT NULL,
  `change_by` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dynamic_field_name` (`name`),
  KEY `FK_dynamic_field_create_by_id` (`create_by`),
  KEY `FK_dynamic_field_change_by_id` (`change_by`),
  KEY `FK_dynamic_field_valid_id_id` (`valid_id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dynamic_field`
--

LOCK TABLES `dynamic_field` WRITE;
/*!40000 ALTER TABLE `dynamic_field` DISABLE KEYS */;
INSERT INTO `dynamic_field` VALUES (1,1,'ProcessManagementProcessID','ProcessManagementProcessID',1,'Text','Ticket','---\nDefaultValue: \'\'\n',1,'2015-06-03 13:02:09',1,'2015-06-03 13:02:09',1),(2,1,'ProcessManagementActivityID','ProcessManagementActivityID',2,'Text','Ticket','---\nDefaultValue: \'\'\n',1,'2015-06-03 13:02:09',1,'2015-06-03 13:18:06',1),(4,0,'category','Category',3,'Text','Ticket','---\nDefaultValue: \'\'\nLink: \'\'\n',1,'2015-06-03 13:19:21',1,'2015-06-03 13:19:21',1),(5,0,'type','Type',4,'Dropdown','Ticket','---\nDefaultValue: \'1\'\nLink: \'\'\nPossibleNone: \'0\'\nPossibleValues:\n  \'1\': Incident\n  \'2\': Event\nTranslatableValues: \'0\'\nTreeView: \'0\'\n',1,'2015-06-03 13:20:13',1,'2015-06-03 13:20:13',1),(6,0,'element','Element',5,'Text','Ticket','---\nDefaultValue: \'\'\nLink: \'\'\n',1,'2015-06-03 13:20:48',1,'2015-06-03 13:20:48',1),(7,0,'global','Global',6,'Dropdown','Ticket','---\nDefaultValue: \'2\'\nLink: \'\'\nPossibleNone: \'0\'\nPossibleValues:\n  \'1\': Yes\n  \'2\': No\nTranslatableValues: \'0\'\nTreeView: \'0\'\n',1,'2015-06-03 13:21:47',1,'2015-06-03 13:21:47',1);
/*!40000 ALTER TABLE `dynamic_field` ENABLE KEYS */;
UNLOCK TABLES;
