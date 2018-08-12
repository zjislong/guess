 CREATE TABLE IF NOT EXISTS `GPlayer` (
  `PlayerID` varchar(100) NOT NULL COMMENT 'UID',
  `Name` varchar(100) DEFAULT '' COMMENT '昵称',
  `Head` varchar(300) DEFAULT '' COMMENT '头像',
  `Gender` varchar(100) DEFAULT '' COMMENT '性别',
  `City` varchar(100) DEFAULT '' COMMENT '市',
  `Province` varchar(100) DEFAULT '' COMMENT '省',
  `Country` varchar(100) DEFAULT '' COMMENT '国家',
  `Gold` int(10) unsigned DEFAULT '0' COMMENT '金币',
  `Score` int(10) unsigned DEFAULT '0' COMMENT '积分',
  `Title` smallint(2) unsigned DEFAULT '0' COMMENT '称号',
  `LoopTime` int(10) unsigned DEFAULT '0' COMMENT '上次循环操作时间',
  PRIMARY KEY (`PlayerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家基础信息';

 CREATE TABLE IF NOT EXISTS `GPublicData` (
  `Key` varchar(20) NOT NULL COMMENT 'Key',
  `Value` varchar(100) DEFAULT '' COMMENT '值',
  PRIMARY KEY (`Key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='游戏公共数据';

DELIMITER /
CREATE PROCEDURE `PCreateRankTable` (IN RankTableName varchar(20))
BEGIN
    SET @sql=concat("CREATE TABLE IF NOT EXISTS `", RankTableName, "` (
      `Key` varchar(50) NOT NULL COMMENT 'Key',
      `Value` int(6) unsigned DEFAULT '0' COMMENT '值',
      `Rank` int(6) unsigned DEFAULT '0' COMMENT '排名',
      PRIMARY KEY (`Key`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='排行榜';");
    PREPARE exectable FROM @sql;
    EXECUTE exectable;
END;/
DELIMITER ;
