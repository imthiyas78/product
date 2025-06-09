DROP PROCEDURE IF EXISTS EZEE_SP_RPT_VEHILCE_PAYMENT_REPORT;
DELIMITER $$
CREATE PROCEDURE EZEE_SP_RPT_VEHILCE_PAYMENT_REPORT(IN pitNamespaceId INT, IN pcrFromDate VARCHAR(25), IN pcrToDate VARCHAR(25), IN pcrVehicleCode VARCHAR(30))
/*
* Procedure Name       : EZEE_SP_RPT_VEHILCE_PAYMENT
* 
* Procedure Code       : RQO48AX2
* 
* Purpose              : Find cargo by transit organization
*
* Input                : Entity Type
*
* Output               : None
*
* Returns              : Compressed Date
*
* Dependencies
*
*     Tables           : None
*
*     Functions        : None
* 						  
*     Procedures       : None
*
* Revision History:
* 
*    1.1 - 2024/09/21               Ezee Info
*    Venkatesan                     Orginal Code
*    1.2 - 2024/09/24               Ezee Info
*    Venkatesan                     arrival_at and departure_at exposed
*    1.3 - 2024/10/18               Ezee Info
*    Venkatesan                     advance amount and extra odometer exposed 
*    1.4 - 2024/10/30               Ezee Info
*    Venkatesan                     trip date and vehicle tariff type exposed
*    1.5 - 2024/12/02               Ezee Info
*    Venkatesan                     start odometer and total_amount recalculate
*    1.6 - 2025/05/09               Ezee Info
*    Sathiya                        fine tunning and correction
*    1.7 - 2025/05/17               Ezee Info
*    Javakar                        performance fine tune
*
*/
BEGIN
/*
*----------------------------------------------------------------------------------------------------
* Variable Declare
*-----------------------------------------------------------------------------------------------------
*/
		DECLARE	litVehicleId 				 INT DEFAULT 0;
		DECLARE litTransitModel              INT DEFAULT 0;
		
/*
*-----------------------------------------------------------------------------------------------------
*  Variable Initialized
*------------------------------------------------------------------------------------------------------
*/
	 
	 

	 IF (EZEE_FN_ISNOTNULL(pcrVehicleCode)) THEN
		SELECT id INTO litVehicleId FROM bus_vehicle WHERE code = pcrVehicleCode;
	 END IF;
	 
	 SELECT transit_location_model_id INTO litTransitModel FROM cargo_settings WHERE namespace_id = pitNamespaceId;
	 
	 DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_CARGO_TRANSIT_DETAILS_01;
	 CREATE TEMPORARY TABLE TEMP_RPT_CARGO_TRANSIT_DETAILS_01(
	   transit_id                   INT           NOT NULL DEFAULT 0
	 , transit_code                 VARCHAR(30)       NULL 
	 , alias_code                   VARCHAR(30)   NOT NULL
	 , from_station_id              INT           NOT NULL DEFAULT 0
	 , to_station_id                INT           NOT NULL DEFAULT 0
	 , activity_type                CHAR(10)          NULL
	 , local_activity_type          CHAR(05)          NULL
	 , from_station_code            VARCHAR(25)       NULL
	 , to_station_code              VARCHAR(25)       NULL
	 , from_station_name            VARCHAR(25)       NULL
	 , to_station_name              VARCHAR(25)       NULL
	 , trip_date                    VARCHAR(25)       NULL
	 , station_based_model          VARCHAR(10)       NULL
	 , branch_based_model           VARCHAR(10)       NULL
	 , from_organization_id         INT           NOT NULL DEFAULT 0
	 , to_organization_id           INT           NOT NULL DEFAULT 0
	 , from_organization_code       VARCHAR(30)       NULL
	 , from_organization_short_code  CHAR(05)         NULL
	 , from_organization_name       VARCHAR(30)       NULL
	 , to_organization_code         VARCHAR(30)       NULL
	 , to_organization_short_code    CHAR(05)         NULL
	 , to_organization_name         VARCHAR(30)       NULL
	 , transit_status               INT           NOT NULL DEFAULT 0
	 , vehicle_id                   INT           NOT NULL DEFAULT 0
	 , arrival_at                   VARCHAR(25)       NULL
	 , departure_at                 VARCHAR(25)       NULL
	 , fuel_date                    VARCHAR(20)       NULL
     , fuel_litres                  VARCHAR(150)      NULL
     , price_per_litres             VARCHAR(150)      NULL
     , fuel_total_amount            VARCHAR(150)      NULL
	 , registration_number          VARCHAR(20)       NULL
	 , total_amount                 DECIMAL(8,2)      NULL
     , total_paid_amount            DECIMAL(8,2)      NULL
     , transaction_at               VARCHAR(25)       NULL
     , acknowledgement_status_id 	INT           NOT NULL DEFAULT 0
     , payment_model_id             INT           NOT NULL  DEFAULT 0
	 , start_odometer               INT               NULL
	 , end_odometer                 INT               NULL
	 , local_start_odometer         INT               NULL
	 , local_end_odometer           INT               NULL
	 , total_odometer               INT               NULL
	 , total_transit_odometer       INT               NULL
	 , local_total_odometer         INT               NULL DEFAULT 0
	 , total_advance_amount         INT               NULL DEFAULT 0
	 , total_transit_amount         DECIMAL(8,2)      NULL DEFAULT 0
	 , local_arrival_at             VARCHAR(25)       NULL
	 , local_departure_at           VARCHAR(25)       NULL
	 , load_measurement             CHAR(05)          NULL
	 , transporter_contact_id       INT               NULL
	 , transporter_name             VARCHAR(30)       NULL
	 , transporter_mobile_number    VARCHAR(15)       NULL
     , load_capacity                INT               NULL
	 , lookup_id                    INT               NULL
	 , extra_odometer               INT               NULL
	 , approved_odometer            INT               NULL
     , action_type                  CHAR(05)          NULL
     , vehicle_tariff_type          INT               NULL DEFAULT 0
	 , ownership_type_id            INT           NOT NULL DEFAULT 0
	 , extra_amount                 DECIMAL(8,2)      NULL
	 , active_flag                  INT           NOT NULL DEFAULT 1
	 );
	 
	 INSERT INTO TEMP_RPT_CARGO_TRANSIT_DETAILS_01(transit_id, transit_code, alias_code, activity_type, station_based_model, branch_based_model, from_station_id, to_station_id, from_organization_id, to_organization_id, transit_status, vehicle_id, registration_number, lookup_id, trip_date)
     SELECT ct.id, ct.code, ct.alias_code, ct.activity_type, CONCAT(ct.from_station_id,"_",ct.to_station_id), CONCAT( ct.from_organization_id,"_",ct.to_organization_id), ct.from_station_id, ct.to_station_id, ct.from_organization_id, ct.to_organization_id, ct.transit_status, ct.vehicle_id, ct.registration_number, ct.lookup_id, ct.trip_date
     FROM cargo_transit ct, cargo_transit_details ctd WHERE ct.id = ctd.cargo_transit_id AND ct.transit_status = 2 AND ct.namespace_id = ctd.namespace_id AND ct.namespace_id = pitNamespaceId AND ct.trip_date BETWEEN pcrFromDate AND pcrToDate
     AND ct.active_flag = 1 GROUP BY ct.id;
     
     CREATE INDEX INX_TEMP_RPT_CARGO_TRANSIT_DETAILS_01 ON TEMP_RPT_CARGO_TRANSIT_DETAILS_01(vehicle_id, transit_id, active_flag);
     
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_CARGO_TRANSIT_DETAILS_02;
     CREATE TEMPORARY TABLE TEMP_RPT_CARGO_TRANSIT_DETAILS_02(
       cargo_transit_id      INT NOT NULL DEFAULT 0
     , start_odometer        INT NULL
     , end_odometer          INT NULL
     , activity_type         CHAR(10) NULL
     , arrival_at            VARCHAR(25)     NULL
     , departure_at          VARCHAR(25)     NULL
     , approved_odometer     INT             NULL
     , action_type           CHAR(05)        NULL
     );
     
     INSERT INTO TEMP_RPT_CARGO_TRANSIT_DETAILS_02(cargo_transit_id, start_odometer, end_odometer, activity_type, arrival_at, departure_at, approved_odometer, action_type)
     SELECT ct.cargo_transit_id, MIN(ct.start_odometer), MAX(ct.end_odometer), temp.activity_type, MAX(ct.arrival_at), MAX(ct.departure_at), MAX(CASE WHEN EZEE_FN_STRING_SPLIT(ct.additional_details,',',6) != 0 THEN EZEE_FN_STRING_SPLIT(ct.additional_details,',',6) ELSE 0 END), MAX(CASE WHEN EZEE_FN_STRING_SPLIT(ct.additional_details,',',7) != '' THEN EZEE_FN_STRING_SPLIT(ct.additional_details,',',7) ELSE '' END) FROM cargo_transit_details ct, TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp
     WHERE ct.cargo_transit_id = temp.transit_id AND ct.namespace_id = pitNamespaceId AND ct.start_odometer > 0 AND  ct.active_flag = 1 AND temp.lookup_id = 0 GROUP BY temp.transit_id;
     
     CREATE INDEX inx_TEMP_RPT_CARGO_TRANSIT_DETAILS_02_1 ON TEMP_RPT_CARGO_TRANSIT_DETAILS_02(cargo_transit_id);

     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_CARGO_TRANSIT_DETAILS_02 temp2
	 SET temp.start_odometer = temp2.start_odometer, temp.end_odometer = temp2.end_odometer, temp.total_transit_odometer = temp2.end_odometer - temp2.start_odometer
	 , temp.arrival_at = temp2.arrival_at, temp.departure_at = temp2.departure_at, temp.approved_odometer = temp2.approved_odometer
	 , temp.action_type = temp2.action_type, temp.activity_type = temp2.activity_type
	 WHERE temp.transit_id = temp2.cargo_transit_id;
     
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_CARGO_TRANSIT_DETAILS_03;
     CREATE TEMPORARY TABLE TEMP_RPT_CARGO_TRANSIT_DETAILS_03(
       cargo_transit_id      INT NOT NULL DEFAULT 0
     , start_odometer        INT NULL
     , end_odometer          INT NULL
     , activity_type         CHAR(10) NULL
     , arrival_at            VARCHAR(25)     NULL
     , departure_at          VARCHAR(25)     NULL
     );
     
     INSERT INTO TEMP_RPT_CARGO_TRANSIT_DETAILS_03(cargo_transit_id, start_odometer, end_odometer, activity_type, arrival_at, departure_at)
     SELECT temp.lookup_id, MIN(ct.start_odometer), MAX(ct.end_odometer), temp.activity_type, MAX(ct.arrival_at), MAX(ct.departure_at) FROM cargo_transit_details ct, TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp
     WHERE ct.cargo_transit_id = temp.transit_id AND ct.namespace_id = pitNamespaceId AND ct.start_odometer > 0 AND ct.active_flag = 1 AND temp.lookup_id != 0 GROUP BY temp.transit_id;

     CREATE INDEX inx_TEMP_RPT_CARGO_TRANSIT_DETAILS_03_1 ON TEMP_RPT_CARGO_TRANSIT_DETAILS_03(cargo_transit_id);

     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_CARGO_TRANSIT_DETAILS_03 temp2
	 SET temp.local_start_odometer = temp2.start_odometer, temp.local_end_odometer = temp2.end_odometer, temp.local_total_odometer = temp2.end_odometer - temp2.start_odometer
	 , temp.local_activity_type = temp2.activity_type, temp.local_arrival_at = temp2.arrival_at, temp.local_departure_at = temp2.departure_at
	 WHERE temp.transit_id = temp2.cargo_transit_id;
     
     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, station st SET temp.from_station_code = st.code, temp.from_station_name = st.name WHERE temp.from_station_id = st.id;
     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, station st SET temp.to_station_code = st.code, temp.to_station_name = st.name WHERE temp.to_station_id = st.id;

     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, organization org SET temp.from_organization_code = org.code, temp.from_organization_short_code = org.short_code, temp.from_organization_name = org.name WHERE temp.from_organization_id = org.id;
     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, organization org SET temp.to_organization_code = org.code, temp.to_organization_short_code = org.short_code, temp.to_organization_name = org.name WHERE temp.to_organization_id = org.id;
     
     /**Vehicle Details*/
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_CARGO_VEHICLE_DETAILS_01;
     CREATE TEMPORARY TABLE TEMP_RPT_CARGO_VEHICLE_DETAILS_01(
       vehicle_id              INT NOT NULL DEFAULT 0
     , load_measurement        CHAR(05) NULL
     , load_capacity           INT NULL
     , transporter_contact_id  INT NULL
     , ownership_type_id       INT NULL
     );

     INSERT INTO TEMP_RPT_CARGO_VEHICLE_DETAILS_01(vehicle_id, load_measurement, load_capacity, transporter_contact_id, ownership_type_id)
     SELECT bs.id, bs.load_measurement, EZEE_FN_STRING_SPLIT(bs.capacity_details,',',4), bs.transporter_contact_id, bs.ownership_type
     FROM bus_vehicle bs, TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp WHERE (bs.id = temp.vehicle_id OR bs.registation_number = temp.registration_number) AND temp.active_flag = 1;
     
     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_CARGO_VEHICLE_DETAILS_01 temp2 SET temp.load_measurement = temp2.load_measurement, temp.load_capacity = temp2.load_capacity, temp.transporter_contact_id = temp2.transporter_contact_id, temp.ownership_type_id = temp2.ownership_type_id WHERE temp.vehicle_id = temp2.vehicle_id AND temp.active_flag = 1;
     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, contact ct SET temp.transporter_name = ct.name, temp.transporter_mobile_number = ct.mobile WHERE temp.transporter_contact_id = ct.id AND temp.active_flag = 1;
     
     IF (litVehicleId != 0) THEN
     	UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 SET active_flag = 0 WHERE vehicle_id != litVehicleId;
     END IF;
     
     /**Distinct transit id*/
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_CARGO_TRANSIT_DETAILS_05;
     CREATE TEMPORARY TABLE TEMP_RPT_CARGO_TRANSIT_DETAILS_05(
       transit_id           INT NOT NULL DEFAULT 0
     , active_flag          INT NOT NULL DEFAULT 1  
     );
     
     INSERT INTO TEMP_RPT_CARGO_TRANSIT_DETAILS_05(transit_id)
     SELECT DISTINCT(transit_id) FROM TEMP_RPT_CARGO_TRANSIT_DETAILS_01 WHERE active_flag = 1;
    
     /**transit fuel details*/
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_CARGO_TRANSIT_FUEL_DETAILS_01;
     CREATE TEMPORARY TABLE TEMP_RPT_CARGO_TRANSIT_FUEL_DETAILS_01(
       transit_id                     INT NOT NULL DEFAULT 0
     , fuel_litres                    VARCHAR(150)   NULL
     , price_per_litres               VARCHAR(150)   NULL
     , fuel_total_amount              VARCHAR(150)   NULL
     );
     
     INSERT INTO TEMP_RPT_CARGO_TRANSIT_FUEL_DETAILS_01(transit_id, fuel_litres, price_per_litres, fuel_total_amount)
     SELECT tfd.transit_id, GROUP_CONCAT(tfd.litres), GROUP_CONCAT(tfd.price_per_litre), GROUP_CONCAT(tfd.total_amount)
     FROM transit_fuel_details tfd, TEMP_RPT_CARGO_TRANSIT_DETAILS_05 temp WHERE tfd.transit_id = temp.transit_id AND tfd.namespace_id = pitNamespaceId AND temp.active_flag = 1 GROUP BY temp.transit_id;
     
     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_CARGO_TRANSIT_FUEL_DETAILS_01 temp2 SET temp.fuel_litres = temp2.fuel_litres, temp.price_per_litres = temp2.price_per_litres, temp.fuel_total_amount = temp2.fuel_total_amount WHERE temp.transit_id = temp2.transit_id AND temp.active_flag = 1;
     
     /**transit transaction details*/
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_TRANSIT_TRANSACTION_DETIALS_01;
     CREATE TEMPORARY TABLE TEMP_RPT_TRANSIT_TRANSACTION_DETIALS_01(
       transit_id                INT NOT NULL DEFAULT 0
     , total_amount              DECIMAL(8,2)  NULL
     , total_paid_amount         DECIMAL(8,2)  NULL
     , transaction_at            VARCHAR(25)   NULL
     , acknowledgement_status_id 	INT   NOT NULL	DEFAULT 0
     , payment_model_id           INT NOT NULL  DEFAULT 0
     );
     
     INSERT INTO TEMP_RPT_TRANSIT_TRANSACTION_DETIALS_01(transit_id, total_amount, total_paid_amount, transaction_at, acknowledgement_status_id, payment_model_id)
     SELECT tt.transit_id, SUM(tt.amount), SUM(tt.paid_amount), tt.transaction_at, tt.acknowledge_status_id, tt.payment_mode_id FROM transit_transaction tt, TEMP_RPT_CARGO_TRANSIT_DETAILS_05 temp WHERE tt.transit_id = temp.transit_id AND tt.namespace_id = pitNamespaceId AND tt.cashbook_type_code LIKE '%ADVANCE%' AND temp.active_flag = 1 GROUP BY tt.transit_id;
     
     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_TRANSIT_TRANSACTION_DETIALS_01 temp2 SET temp.total_advance_amount = temp2.total_amount, temp.total_paid_amount = temp2.total_paid_amount, temp.transaction_at = temp2.transaction_at, temp.acknowledgement_status_id = temp2.acknowledgement_status_id, temp.payment_model_id = temp. payment_model_id
     WHERE temp.transit_id = temp2.transit_id AND temp.active_flag = 1;
     
     /**vehicle traiff*/
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_VEHICLE_TRAIFF_01;
     CREATE TEMPORARY TABLE TEMP_RPT_VEHICLE_TRAIFF_01(
       vehicle_id             VARCHAR(150)   NOT NULL DEFAULT 0
     , ownership_type_id      INT NOT NULL DEFAULT 0
     , trariff_type           CHAR(05)       NULL
     , station_based_model    VARCHAR(500)   NULL
     , branch_based_model     VARCHAR(500)   NULL
     , station_route_model    VARCHAR(500)   NULL
     , branch_route_model     VARCHAR(500)   NULL
     , start_unit             VARCHAR(30)    NULL
     , end_unit               VARCHAR(30)    NULL
     , tariff_odometer        VARCHAR(30)    NULL
     , reference_type         INT            NULL
     , vehicle_tariff_type    INT            NULL DEFAULT 0
     , total_amount           DECIMAL(8,2)   NULL DEFAULT 0
     , extra_amount           VARCHAR(30)    NULL
     );
     
     INSERT INTO TEMP_RPT_VEHICLE_TRAIFF_01(vehicle_id, trariff_type, ownership_type_id, station_based_model, branch_based_model, station_route_model, branch_route_model, start_unit, end_unit, tariff_odometer, total_amount, extra_amount, reference_type, vehicle_tariff_type)
     SELECT tt.vehicle_id, tt.tariff_type, tt.ownership_type_id, (CASE WHEN reference_type = 2 THEN reference_id END) AS station_based_model, (CASE WHEN reference_type = 1 THEN reference_id END) AS branch_based_model, (CASE WHEN reference_type = 3 THEN reference_id END) AS start_unit, (CASE WHEN reference_type = 4 THEN reference_id END) AS end_unit,
     EZEE_FN_STRING_SPLIT(ttd.rate_card_details,',',1) AS start_unit, EZEE_FN_STRING_SPLIT(ttd.rate_card_details,',',2) AS end_unit, EZEE_FN_STRING_SPLIT(ttd.rate_card_details,',',3) AS total_odometer, EZEE_FN_STRING_SPLIT(ttd.rate_card_details,',', 4) AS total_amount, EZEE_FN_STRING_SPLIT(ttd.rate_card_details,',', 5) AS extra_amount, ttd.reference_type, (CASE WHEN EZEE_FN_STRING_SPLIT(ttd.rate_card_details,',',6) != '' THEN EZEE_FN_STRING_SPLIT(ttd.rate_card_details,',',6) ELSE 0 END) AS vehicle_tariff_type
     FROM vehicle_tariff tt, vehicle_tariff_details ttd WHERE tt.id = ttd.vehcile_tariff_id AND tt.namespace_id = ttd.namespace_id AND tt.namespace_id = pitNamespaceId AND tt.active_flag = 1;
     
     CREATE INDEX INX_TEMP_RPT_VEHICLE_TRAIFF_01 ON TEMP_RPT_VEHICLE_TRAIFF_01(vehicle_id);
     
     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 SET total_odometer = total_transit_odometer + local_total_odometer WHERE active_flag = 1;
    
     /**traiff advance amount calculation*/
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_VEHICLE_TRAIFF_02;
     CREATE TEMPORARY TABLE TEMP_RPT_VEHICLE_TRAIFF_02(
       vehicle_id             INT NOT NULL DEFAULT 0
     , transit_id             INT NOT NULL DEFAULT 0  
     , extra_odometer         INT     NULL
     , vehicle_tariff_type    INT            NULL 
     , extra_amount           DECIMAL(8,2)   NULL
     , total_amount           DECIMAL(8,2)   NULL DEFAULT 0
     );
	 
     IF (litTransitModel = 1) THEN
     	INSERT INTO TEMP_RPT_VEHICLE_TRAIFF_02 (vehicle_id, total_amount, transit_id, extra_odometer, vehicle_tariff_type, extra_amount)
     	SELECT temp.vehicle_id, (CASE WHEN tariff_odometer < temp.total_odometer AND temp.action_type = 1 AND temp.approved_odometer != 0 THEN ((temp.approved_odometer)*temp2.extra_amount) + temp2.total_amount WHEN tariff_odometer >= temp.total_odometer THEN temp2.total_amount END) AS total_amount, temp.transit_id, (CASE WHEN tariff_odometer < temp.total_odometer THEN temp.total_odometer - tariff_odometer END) AS extra_odometer, temp2.vehicle_tariff_type, temp2.extra_amount
     	FROM TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_VEHICLE_TRAIFF_01 temp2 WHERE FIND_IN_SET(temp.station_based_model, temp2.station_route_model) AND temp2.reference_type = 3 AND FIND_IN_SET(temp.vehicle_id, temp2.vehicle_id) AND active_flag = 1 GROUP BY transit_id;

     	INSERT INTO TEMP_RPT_VEHICLE_TRAIFF_02 (vehicle_id, total_amount, transit_id, extra_odometer, vehicle_tariff_type, extra_amount)
     	SELECT temp.vehicle_id, (CASE WHEN tariff_odometer < temp.total_odometer AND temp.action_type = 1 AND temp.approved_odometer != 0 THEN ((temp.approved_odometer)*temp2.extra_amount) + temp2.total_amount WHEN tariff_odometer >= temp.total_odometer THEN temp2.total_amount END) AS total_amount, temp.transit_id, (CASE WHEN tariff_odometer < temp.total_odometer THEN temp.total_odometer - tariff_odometer END) AS extra_odometer, temp2.vehicle_tariff_type, temp2.extra_amount 
     	FROM TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_VEHICLE_TRAIFF_01 temp2 WHERE FIND_IN_SET(temp.from_station_id, temp2.station_based_model) AND temp2.reference_type = 2 AND FIND_IN_SET(temp.vehicle_id, temp2.vehicle_id) AND active_flag = 1 GROUP BY transit_id;
         
     ELSEIF (litTransitModel = 2) THEN
     	INSERT INTO TEMP_RPT_VEHICLE_TRAIFF_02 (vehicle_id, total_amount, transit_id, extra_odometer, vehicle_tariff_type, extra_amount)
     	SELECT temp.vehicle_id, (CASE WHEN tariff_odometer < temp.total_odometer AND temp.action_type = 1 AND temp.approved_odometer != 0 THEN ((temp.approved_odometer)*temp2.extra_amount) + temp2.total_amount WHEN tariff_odometer >= temp.total_odometer THEN temp2.total_amount WHEN tariff_odometer < temp.total_odometer AND temp.action_type = 0 THEN temp2.total_amount END) AS total_amount, temp.transit_id, 
     	(CASE WHEN tariff_odometer < temp.total_odometer THEN temp.total_odometer - tariff_odometer END) AS extra_odometer, temp2.vehicle_tariff_type, temp2.extra_amount 
     	FROM TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_VEHICLE_TRAIFF_01 temp2 WHERE FIND_IN_SET(temp.branch_based_model, temp2.branch_route_model) AND temp2.reference_type = 4 AND FIND_IN_SET(temp.vehicle_id, temp2.vehicle_id) AND temp2.vehicle_tariff_type = 1 AND active_flag = 1 GROUP BY transit_id;
     	
     	INSERT INTO TEMP_RPT_VEHICLE_TRAIFF_02 (vehicle_id, total_amount, transit_id, extra_odometer, vehicle_tariff_type, extra_amount)
     	SELECT temp.vehicle_id, (CASE WHEN tariff_odometer < temp.total_odometer AND temp.action_type = 1 AND temp.approved_odometer != 0 THEN ((temp.approved_odometer)*temp2.extra_amount) + temp2.total_amount WHEN tariff_odometer >= temp.total_odometer THEN temp2.total_amount WHEN tariff_odometer < temp.total_odometer AND temp.action_type = 0 THEN temp2.total_amount END) AS total_amount, temp.transit_id, 
     	(CASE WHEN tariff_odometer < temp.total_odometer THEN temp.total_odometer - tariff_odometer END) AS extra_odometer , temp2.vehicle_tariff_type, temp2.extra_amount
     	FROM TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_VEHICLE_TRAIFF_01 temp2 WHERE FIND_IN_SET(temp.from_organization_id, temp2.branch_based_model) AND (FIND_IN_SET(2, temp.activity_type) OR FIND_IN_SET(3, temp.activity_type)) AND temp2.reference_type = 1 AND FIND_IN_SET(temp.vehicle_id, temp2.vehicle_id) AND temp2.vehicle_tariff_type = 1 AND active_flag = 1 GROUP BY transit_id;
        
     	INSERT INTO TEMP_RPT_VEHICLE_TRAIFF_02 (vehicle_id, total_amount, transit_id, extra_odometer, vehicle_tariff_type, extra_amount)
     	SELECT temp.vehicle_id, (CASE WHEN temp.total_odometer != 0 AND temp.action_type = 1 AND temp.approved_odometer != 0 THEN ((temp.approved_odometer)*temp2.extra_amount) + (temp.total_odometer - temp.approved_odometer)*temp2.extra_amount WHEN tariff_odometer >= temp.total_odometer THEN temp2.total_amount WHEN temp.action_type = 0 THEN ((temp.total_odometer)*temp2.extra_amount) END) AS total_amount, temp.transit_id, 
     	(CASE WHEN tariff_odometer < temp.total_odometer THEN temp.total_odometer - tariff_odometer END) AS extra_odometer , temp2.vehicle_tariff_type, temp2.extra_amount
     	FROM TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_VEHICLE_TRAIFF_01 temp2 WHERE FIND_IN_SET(temp.branch_based_model, temp2.branch_route_model) AND temp2.reference_type = 4 AND FIND_IN_SET(temp.vehicle_id, temp2.vehicle_id) AND temp2.vehicle_tariff_type = 2 AND active_flag = 1 GROUP BY transit_id;

     	INSERT INTO TEMP_RPT_VEHICLE_TRAIFF_02 (vehicle_id, total_amount, transit_id, extra_odometer, vehicle_tariff_type, extra_amount)
     	SELECT temp.vehicle_id, (CASE WHEN temp.total_odometer != 0 AND temp.action_type = 1 AND temp.approved_odometer != 0 THEN ((temp.approved_odometer)*temp2.extra_amount) + (temp.total_odometer - temp.approved_odometer)*temp2.extra_amount WHEN tariff_odometer >= temp.total_odometer THEN temp2.total_amount WHEN temp.action_type = 0 THEN ((temp.total_odometer)*temp2.extra_amount) END) AS total_amount, temp.transit_id, 
     	(CASE WHEN tariff_odometer < temp.total_odometer THEN temp.total_odometer - tariff_odometer END) AS extra_odometer, temp2.vehicle_tariff_type, temp2.extra_amount 
     	FROM TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_VEHICLE_TRAIFF_01 temp2 WHERE FIND_IN_SET(temp.from_organization_id, temp2.branch_based_model) AND FIND_IN_SET(2, temp.activity_type) AND temp2.reference_type = 1 AND FIND_IN_SET(temp.vehicle_id, temp2.vehicle_id) AND temp2.vehicle_tariff_type = 2 AND active_flag = 1 GROUP BY transit_id;
       
     END IF;
     
     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01 temp, TEMP_RPT_VEHICLE_TRAIFF_02 temp2 SET total_transit_amount = temp2.total_amount, temp.extra_odometer = temp2.extra_odometer, temp.vehicle_tariff_type = temp2.vehicle_tariff_type, temp.extra_amount = temp2.extra_amount WHERE temp.vehicle_id = temp2.vehicle_id AND temp.transit_id = temp2.transit_id AND temp.active_flag = 1;
     UPDATE TEMP_RPT_CARGO_TRANSIT_DETAILS_01  SET active_flag = 0 WHERE total_transit_amount = 0 AND (vehicle_tariff_type = 0 OR EZEE_FN_ISNULL(vehicle_tariff_type)) AND active_flag = 1;
     
     SELECT transit_code, alias_code, from_station_code, from_station_name, to_station_code, to_station_name, from_organization_code, from_organization_name, from_organization_short_code, to_organization_code, to_organization_name, to_organization_short_code, start_odometer, end_odometer, registration_number, total_odometer, total_transit_odometer,(CASE WHEN vehicle_tariff_type = 2 THEN extra_odometer END) AS extra_odometer, action_type, approved_odometer,
     (CONCAT(activity_type,',',(CASE WHEN local_activity_type != 0 THEN local_activity_type ELSE '' END))) AS activity_type, fuel_litres, price_per_litres, fuel_total_amount, total_advance_amount, total_paid_amount, total_transit_amount, local_start_odometer, local_end_odometer, local_total_odometer, load_capacity, load_measurement, transporter_name, transporter_mobile_number, arrival_at, departure_at, local_arrival_at, local_departure_at, trip_date,
     (CASE WHEN ownership_type_id = 1 THEN 'OWN' WHEN ownership_type_id = 2 THEN 'ATCH'  WHEN ownership_type_id = 3 THEN 'HIRE' END) AS ownership_type, vehicle_tariff_type, extra_amount AS km_per_amount
     FROM TEMP_RPT_CARGO_TRANSIT_DETAILS_01 WHERE active_flag = 1 AND lookup_id = 0 GROUP BY transit_id; 
     
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_CARGO_TRANSIT_DETAILS_01;
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_CARGO_TRANSIT_DETAILS_02;
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_CARGO_TRANSIT_DETAILS_03;
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_CARGO_VEHICLE_DETAILS_01;
     DROP TEMPORARY TABLE IF EXISTS TEMP_RPT_TRANSIT_TRANSACTION_DETIALS_01;
     
END $$
DELIMITER ;