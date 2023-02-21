-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- 主机： localhost
-- 生成日期： 2023-02-21 13:56:07
-- 服务器版本： 10.5.18-MariaDB-0+deb11u1
-- PHP 版本： 8.0.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 数据库： `test`
--

-- --------------------------------------------------------

--
-- 表的结构 `ban`
--

CREATE TABLE `ban` (
  `id` bigint(20) NOT NULL,
  `unknown` varchar(32) DEFAULT NULL COMMENT 'ip或手机号或其他',
  `type` varchar(32) DEFAULT NULL COMMENT '类型 ip email 之类',
  `reason` varchar(64) DEFAULT NULL COMMENT '封禁原因',
  `time_lift` int(11) DEFAULT NULL COMMENT '解封时间',
  `time` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `ban_count`
--

CREATE TABLE `ban_count` (
  `id` bigint(20) NOT NULL,
  `unknown` varchar(32) DEFAULT NULL COMMENT 'ip或手机号或其他',
  `type` varchar(32) DEFAULT NULL COMMENT '类型 ip email 之类',
  `reason` varchar(64) DEFAULT NULL COMMENT '封禁原因',
  `time` int(11) DEFAULT NULL COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `ban_rule`
--

CREATE TABLE `ban_rule` (
  `id` bigint(20) NOT NULL COMMENT '封禁规则',
  `second` bigint(20) DEFAULT NULL COMMENT '规定时间',
  `number` bigint(20) DEFAULT NULL COMMENT '最大错误次数',
  `time_ban` int(11) DEFAULT NULL COMMENT '封禁时长',
  `time` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `bug_traces`
--

CREATE TABLE `bug_traces` (
  `id` bigint(20) NOT NULL,
  `re_code` varchar(32) DEFAULT NULL,
  `msg` varchar(256) DEFAULT NULL,
  `traces` text DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `time` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `code_error`
--

CREATE TABLE `code_error` (
  `id` bigint(20) NOT NULL,
  `str` text DEFAULT NULL,
  `time` int(11) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `time_completion` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL COMMENT '1处理完成 2忽略'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `sms`
--

CREATE TABLE `sms` (
  `id` bigint(20) NOT NULL,
  `code` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `time` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 表的结构 `user`
--

CREATE TABLE `user` (
  `id` bigint(20) NOT NULL,
  `token` varchar(32) DEFAULT NULL,
  `headurl` varchar(32) DEFAULT NULL,
  `time` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 转储表的索引
--

--
-- 表的索引 `ban`
--
ALTER TABLE `ban`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- 表的索引 `ban_count`
--
ALTER TABLE `ban_count`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- 表的索引 `ban_rule`
--
ALTER TABLE `ban_rule`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- 表的索引 `bug_traces`
--
ALTER TABLE `bug_traces`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`),
  ADD UNIQUE KEY `traces` (`traces`) USING HASH;

--
-- 表的索引 `code_error`
--
ALTER TABLE `code_error`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- 表的索引 `sms`
--
ALTER TABLE `sms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- 表的索引 `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `ban`
--
ALTER TABLE `ban`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ban_count`
--
ALTER TABLE `ban_count`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `ban_rule`
--
ALTER TABLE `ban_rule`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '封禁规则';

--
-- 使用表AUTO_INCREMENT `bug_traces`
--
ALTER TABLE `bug_traces`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `code_error`
--
ALTER TABLE `code_error`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `sms`
--
ALTER TABLE `sms`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- 使用表AUTO_INCREMENT `user`
--
ALTER TABLE `user`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
