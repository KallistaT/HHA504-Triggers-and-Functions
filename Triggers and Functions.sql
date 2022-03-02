use synthea;
show tables;

CREATE TABLE KallistaT_CBC(
ID int AUTO_INCREMENT PRIMARY KEY,
patient_ID INT NOT NULL,
last_name VARCHAR(50) NOT NULL,
WBC_Count DECIMAL(3,2),
RBC_Count DECIMAL(3,2),
Hemoglobin DECIMAL(3,2),
Hematocrit DECIMAL(3,2));

insert into KallistaT_CBC(patient_ID, last_name, WBC_Count, RBC_Count, Hemoglobin, Hematocrit)
VALUES (000111, 'Merkel', 8.6, 4.78, 13.7, 41.8), 
(000222, 'Johnson', 10.1, 3.90, 15.5, 39.6),
(000333, 'Macron', 5.5, 6.92, 9.5, 40.3),
(000444, 'Tsai', 12.5, 8.8, 13.4, 45.0); 

SELECT * from KallistaT_CBC;

 ## Trigger
 
 DELIMITER $$
 CREATE TRIGGER RBCError BEFORE INSERT ON KallistaT_CBC
 FOR EACH ROW 
 BEGIN
 IF new.RBC_Count <= 0 THEN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT = 'Red blood cell count must be above 0 million/uL';
 END IF;
 END; 
 $$
 
insert into KallistaT_CBC(patient_ID, last_name, WBC_Count, RBC_Count, Hemoglobin, Hematocrit)
value(000222, 'Johnson', 10.1, 3.90, 15.5, 39.6);
 
## Test Error 
 
insert into KallistaT_CBC(patient_ID, last_name, WBC_Count, RBC_Count, Hemoglobin, Hematocrit)
value (654321, 'Abe', 11.3, 0, 8.6, 35.4);
 
insert into KallistaT_CBC(patient_ID, last_name, WBC_Count, RBC_Count, Hemoglobin, Hematocrit)
value (654321, 'Xi', 12.5, -1, 9.7, 30.4);
 
## Results in Error Code 1644. Red blood cell count must be above 0 million/uL

## Function
 
DELIMITER $$
CREATE FUNCTION rbcrange(RBC_Count DECIMAL (3,2))
RETURNS varchar(20)
BEGIN 
DECLARE RBC_Levels varchar(20);
IF RBC_Count < 3.80 THEN 
SET RBC_Levels = 'Low';

ELSEIF (RBC_Count >= 3.80 AND RBC_Count <= 5.10) THEN
SET RBC_Levels = 'Normal'; 

ELSEIF RBC_Count > 5.10 THEN
SET RBC_Levels = 'High';
END IF;
RETURN (RBC_Levels);
END $$

select patient_ID, last_name, rbcrange(RBC_Count) from KallistaT_CBC 
