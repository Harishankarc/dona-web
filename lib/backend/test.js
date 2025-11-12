router.get('/fetchgpsdata', async (req, res) => {
    try {

        const url = "https://api.vamosys.com/mobile/getGrpDataForTrustedClients?providerName=VNFLEETS&fcode=VAMTO";
        const apiResponse = await axios.get(url);

        const gpsData = apiResponse.data; 

        if (!Array.isArray(gpsData)) {
            return res.status(400).json({
                status: 'error',
                message: 'Invalid data returned from Vamosys API'
            });
        }

        let finalInsertData = [];

        for (let item of gpsData) {

            const vehicleIdFromAPI = item.vehicleId;  

            // 1️⃣ Fetch vehicle_id and driver_id
            const vehicleQuery = `
                SELECT id, assigned_to 
                FROM vehicles 
                WHERE name = ? LIMIT 1
            `;
            const vehicleRecord = await dbQuery(vehicleQuery, [vehicleIdFromAPI]);

            let vehicle_id = "";
            let driver_id = "";

            if (vehicleRecord.length > 0) {
                vehicle_id = vehicleRecord[0].id || "";
                driver_id = vehicleRecord[0].assigned_to || "";
            }

            // ❗ 2️⃣ Skip if vehicle_id is empty
            if (!vehicle_id) continue;

            let lastSeen = item.lastSeen || "";

            // ❗ 3️⃣ Skip if same vehicle_id + same lastseen already exists
            if (lastSeen) {
                const existsQuery = `
                    SELECT id 
                    FROM gps_vehicle_data
                    WHERE vehicle_id = ? AND lastseen = ?
                    LIMIT 1
                `;
                const exists = await dbQuery(existsQuery, [vehicle_id, lastSeen]);

                if (exists.length > 0) {
                    // Duplicate → skip
                    continue;
                }
            }

            // 4️⃣ Convert todayWorkingHours to float or ""
            let todayWorkingHoursValue = "";
            if (item.todayWorkingHours) {
                let parsed = parseFloat(item.todayWorkingHours);
                todayWorkingHoursValue = isNaN(parsed) ? "" : parsed;
            }

            // 5️⃣ Prepare insert row
            finalInsertData.push([
                vehicle_id,
                item.vehicleId || "",
                driver_id,
                item.vehicleType || "",
                item.regNo || "",
                lastSeen,
                item.odoDistance || "",
                item.distanceCovered || "",
                todayWorkingHoursValue,
                item.latitude || "",
                item.longitude || "",
                item.address || "",
                item.gpsSimICCID || "",
                item.gpsSimNo || "",
                item.oprName || "",
                item.deviceId || "",
                item.status || ""
            ]);
        }

        // If no data to insert
        if (finalInsertData.length === 0) {
            return res.status(200).json({
                status: 'success',
                inserted: 0,
                message: 'Nothing inserted (duplicate or vehicle_id missing).'
            });
        }

        // Insert all rows
        const insertQuery = `
            INSERT INTO gps_vehicle_data
            (
                vehicle_id, vehicle_name, driver_id, vehicle_type, vehicle_registration,
                lastseen, odo_distance, distance_covered, today_working_hours,
                latitude, longitude, address, gps_simiccid, gps_simno,
                opr_name, device_id, status
            )
            VALUES ?
        `;

        await dbQuery(insertQuery, [finalInsertData]);

        return res.status(200).json({
            status: 'success',
            inserted: finalInsertData.length,
            message: 'GPS data inserted successfully'
        });

    } catch (error) {
        console.error("Error inserting GPS data:", error);

        return res.status(500).json({
            status: 'error',
            message: 'Some error occurred. Please try again later.'
        });
    }
});