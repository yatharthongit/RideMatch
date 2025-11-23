-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: ridepool
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int NOT NULL,
  `receiver_id` int NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`),
  KEY `receiver_id` (`receiver_id`),
  CONSTRAINT `chat_messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chat_messages_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_messages`
--

LOCK TABLES `chat_messages` WRITE;
/*!40000 ALTER TABLE `chat_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rides`
--

DROP TABLE IF EXISTS `rides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rides` (
  `id` int NOT NULL AUTO_INCREMENT,
  `driver_id` int DEFAULT NULL,
  `from_addr` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `to_addr` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `seats` int DEFAULT '1',
  `duration` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('scheduled','ongoing','completed','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'scheduled',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `car_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `car_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `car_color` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date NOT NULL,
  `time` time NOT NULL,
  PRIMARY KEY (`id`),
  KEY `driver_id` (`driver_id`),
  CONSTRAINT `rides_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rides`
--

LOCK TABLES `rides` WRITE;
/*!40000 ALTER TABLE `rides` DISABLE KEYS */;
INSERT INTO `rides` VALUES (1,8,'kela','mela',44,NULL,'345','scheduled','2025-11-23 12:15:33','fortuner','fef4453','haha','2025-11-24','18:39:00'),(2,8,'kela','mela',44,NULL,'345','scheduled','2025-11-23 12:15:42','fortuner','fef4453','haha','2025-11-24','18:39:00'),(3,8,'kela','mela',44,NULL,'345','scheduled','2025-11-23 12:17:19','fortuner','fef4453','haha','2025-11-24','18:39:00'),(4,8,'rtr','trrt',44,NULL,'4324','scheduled','2025-11-23 12:18:31','rreg','3445','rfgg','2025-11-24','17:48:00'),(5,8,'sf','fe',3,NULL,'150','scheduled','2025-11-23 12:43:39','Honda City','MP09AB1234','White','2025-11-23','19:13:00'),(6,8,'sf','fe',3,NULL,'150','scheduled','2025-11-23 12:43:47','Honda City','MP09AB1234','White','2025-11-23','19:13:00'),(7,8,'SVVV','Malharganj',3,NULL,'150','scheduled','2025-11-23 12:45:42','Honda City','MP09AB1234','White','2025-11-23','19:15:00'),(8,8,'dd','wd',33,NULL,'24234','scheduled','2025-11-23 12:59:12','34tf','rfggr','refgr','2025-11-23','19:29:00'),(9,8,'tr','tt',3,NULL,'150','scheduled','2025-11-23 13:19:33','Honda City','MP09AB1234','White','2025-11-23','19:49:00'),(10,8,'de','fe',2,NULL,'1999','scheduled','2025-11-23 13:36:32','polo gt','4567','black','2025-11-24','20:06:00'),(11,2,'omaxe','school',1,NULL,'120','scheduled','2025-11-23 15:28:28','Fortuner','3456','Black','2025-11-25','20:58:00'),(12,8,'tuturu','yululu',3,NULL,'150','scheduled','2025-11-23 15:51:10','Honda City','MP09AB1234','White','2025-11-24','21:21:00');
/*!40000 ALTER TABLE `rides` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('rider','driver') COLLATE utf8mb4_unicode_ci DEFAULT 'rider',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `profile_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `idx_users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'string','user@example.com',NULL,'$pbkdf2-sha256$29000$ZKwVAgCAsDZGyLl37v3fWw$WRzaMR.jlediVvLn90zJA7G4d/0j9qYCaw5L7seCFK8','rider','2025-11-23 06:31:40',NULL),(2,'yatharth','yatharth@gmail.com',NULL,'$pbkdf2-sha256$29000$b21NCeF8r7V2LoWQ0lrr3Q$s46a0ueA7699W3vvvVjKulD5xPmXe1jqQi7x7Y3X23A','rider','2025-11-23 07:44:34',NULL),(3,'yatharth12','yatharth12@gmail.com',NULL,'$pbkdf2-sha256$29000$9V7r3ZvTeq/Veq91zrm39g$2IHwDmT2BXq.2fIuJ.kamXa4UncWRjvzcrJg7Ge4br8','rider','2025-11-23 08:55:45',NULL),(4,'yatharth123','yatharth123@gmail.com',NULL,'$pbkdf2-sha256$29000$OafUmnNubW2tNUboPcfYuw$Q6XY5EBc64lNqWQtZd8Ni6tSMj5oKPVjo5L319B1QDg','rider','2025-11-23 09:43:20',NULL),(5,'yatharth69','yatharth69@gmail.com',NULL,'$pbkdf2-sha256$29000$1FprzZlz7l1rTan1vnfufQ$zWjDpeQ2FtKqGr9PJBMoJyDor//NLqj/ap6oBkgpaPE','rider','2025-11-23 10:07:53',NULL),(6,'yatharth6969','yatharth6969@gmail.com',NULL,'$pbkdf2-sha256$29000$GgNg7J0TQsj5vxfinHPOmQ$1x0Nv7pII6ec8Ke8WcD7X8uqdbUlekAuY.yHoUay3.o','rider','2025-11-23 10:08:34',NULL),(7,'lol','lol@gmail.com',NULL,'$pbkdf2-sha256$29000$jnHO.V.LMQag1LpXqrV2bg$G7m9wU2tvtFuhqNOJ7WEn6a9LeIh6Uze87F0VoWSNj4','rider','2025-11-23 10:32:31',NULL),(8,'lala','lala@gmail.com',NULL,'$pbkdf2-sha256$29000$611rTWmNESIEQEjpPUeIUQ$ykc8BTx7SweUhYS1K/HZ.5lXYKjPB106Tgq.6CakWxc','rider','2025-11-23 12:08:50',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-23 21:30:44
