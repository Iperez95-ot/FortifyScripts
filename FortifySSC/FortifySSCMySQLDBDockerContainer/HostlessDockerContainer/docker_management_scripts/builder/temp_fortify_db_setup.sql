    CREATE DATABASE fortify_ssc_db CHARACTER SET latin1 COLLATE latin1_general_cs;
    USE fortify_ssc_db;
    SOURCE /opt/OpenText_Application_Security/OpenText_Application_Security_Application_Files/26.2/sql/mysql/create-tables.sql;
    ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'N0v3ll95';
    FLUSH PRIVILEGES;
    SHOW TABLES;
