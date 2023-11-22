-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: biblioteca
-- ------------------------------------------------------
-- Server version	8.0.31

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
-- Table structure for table `alunos`
--

DROP TABLE IF EXISTS `alunos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alunos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(30) NOT NULL,
  `matricula` varchar(255) NOT NULL,
  `total_livros_pegos` int DEFAULT NULL,
  `id_curso` int NOT NULL,
  `ativo` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_curso` (`id_curso`),
  CONSTRAINT `alunos_ibfk_1` FOREIGN KEY (`id_curso`) REFERENCES `curso` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alunos`
--

LOCK TABLES `alunos` WRITE;
/*!40000 ALTER TABLE `alunos` DISABLE KEYS */;
INSERT INTO `alunos` VALUES (1,'Student 1','M1001',2,1,1),(2,'Student 2','M1002',2,2,1),(3,'Student 3','M1003',0,3,0),(4,'Student 4','M1004',1,4,1),(5,'Student 5','M1005',2,5,1),(6,'Student 6','M1006',1,6,1),(7,'Student 7','M1007',1,7,1),(8,'Student 8','M1008',1,8,1),(9,'Student 9','M1009',0,9,0),(10,'Student 10','M1010',2,10,1);
/*!40000 ALTER TABLE `alunos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `curso`
--

DROP TABLE IF EXISTS `curso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `curso` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(155) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `curso`
--

LOCK TABLES `curso` WRITE;
/*!40000 ALTER TABLE `curso` DISABLE KEYS */;
INSERT INTO `curso` VALUES (1,'Back-End'),(2,'Data Science'),(3,'Web Development'),(4,'Information Security'),(5,'Network Administration'),(6,'Database Management'),(7,'Software Engineering'),(8,'Artificial Intelligence'),(9,'Cybersecurity'),(10,'Front-End'),(11,'IOT');
/*!40000 ALTER TABLE `curso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `emprestimo`
--

DROP TABLE IF EXISTS `emprestimo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emprestimo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `aluno_id` int DEFAULT NULL,
  `livro_id` int DEFAULT NULL,
  `dataRetirada` date DEFAULT NULL,
  `dataPrevistaDeEntrega` date DEFAULT NULL,
  `dataDevolucao` date DEFAULT NULL,
  `multa` float DEFAULT NULL,
  `ativo` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `aluno_id` (`aluno_id`),
  KEY `livro_id` (`livro_id`),
  CONSTRAINT `emprestimo_ibfk_1` FOREIGN KEY (`aluno_id`) REFERENCES `alunos` (`id`),
  CONSTRAINT `emprestimo_ibfk_2` FOREIGN KEY (`livro_id`) REFERENCES `livros` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emprestimo`
--

LOCK TABLES `emprestimo` WRITE;
/*!40000 ALTER TABLE `emprestimo` DISABLE KEYS */;
INSERT INTO `emprestimo` VALUES (1,4,1,'2023-10-28','2023-11-18',NULL,0,1),(2,5,11,'2023-11-23','2023-12-14',NULL,0,1),(3,6,11,'2023-11-20','2023-12-11',NULL,0,1),(4,8,8,'2023-10-01','2023-10-22',NULL,0,1),(5,10,10,'2023-11-03','2023-11-24',NULL,0,1),(6,1,2,'2023-11-04','2023-11-25',NULL,0,1),(7,2,3,'2023-11-05','2023-11-26',NULL,0,1),(8,5,6,'2023-11-08','2023-11-29',NULL,0,1),(9,6,7,'2023-11-09','2023-11-30','2023-11-22',0,1),(10,7,8,'2023-11-10','2023-12-01',NULL,0,1),(11,10,1,'2023-11-13','2023-12-04',NULL,0,1),(12,1,3,'2023-11-14','2023-12-05',NULL,0,1),(13,2,5,'2023-11-15','2023-12-06',NULL,0,1),(14,1,6,'2023-10-15','2023-11-05','2023-11-22',34,1);
/*!40000 ALTER TABLE `emprestimo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `livros`
--

DROP TABLE IF EXISTS `livros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `livros` (
  `id` int NOT NULL AUTO_INCREMENT,
  `titulo` varchar(50) NOT NULL,
  `autor` varchar(50) NOT NULL,
  `copias` int NOT NULL,
  `qtdEmprestimo` int DEFAULT NULL,
  `ativo` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `titulo` (`titulo`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livros`
--

LOCK TABLES `livros` WRITE;
/*!40000 ALTER TABLE `livros` DISABLE KEYS */;
INSERT INTO `livros` VALUES (1,'Introdução à Programação','Autor 11',23,2,1),(2,'Redes e Protocolos','Autor 12',14,1,1),(3,'Segurança Cibernética','Autor 13',28,2,1),(4,'Desenvolvimento Web Moderno','Autor 14',20,0,1),(5,'Machine Learning Avançado','Autor 15',17,1,1),(6,'Inteligência Artificial e Robótica','Autor 16',9,1,1),(7,'Bancos de Dados NoSQL','Autor 17',12,0,1),(8,'Desenvolvimento de Aplicativos Móveis','Autor 18',20,2,1),(9,'Arquitetura de Microserviços','Autor 19',17,0,1),(10,'Cloud Computing e Virtualização Avançada','Autor 20',27,1,1),(11,'IOT-Internet da coisas','Autor 30',0,2,1);
/*!40000 ALTER TABLE `livros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `livrosnaodevolvidosview`
--

DROP TABLE IF EXISTS `livrosnaodevolvidosview`;
/*!50001 DROP VIEW IF EXISTS `livrosnaodevolvidosview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `livrosnaodevolvidosview` AS SELECT 
 1 AS `emprestimo_id`,
 1 AS `livro_titulo`,
 1 AS `aluno_nome`,
 1 AS `dataRetirada`,
 1 AS `dataPrevistaDeEntrega`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `livrosnaodevolvidosview`
--

/*!50001 DROP VIEW IF EXISTS `livrosnaodevolvidosview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `livrosnaodevolvidosview` AS select `e`.`id` AS `emprestimo_id`,`l`.`titulo` AS `livro_titulo`,`a`.`nome` AS `aluno_nome`,`e`.`dataRetirada` AS `dataRetirada`,`e`.`dataPrevistaDeEntrega` AS `dataPrevistaDeEntrega` from ((`emprestimo` `e` join `livros` `l` on((`e`.`livro_id` = `l`.`id`))) join `alunos` `a` on((`e`.`aluno_id` = `a`.`id`))) where ((`e`.`dataDevolucao` is null) and (`e`.`dataPrevistaDeEntrega` < curdate())) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-11-22 20:24:21
