router.post('/createvoucher', async (req, res) => {
    const { vehicles, created_by, voucher_date, branch_id, serial_code } = req.body;

    if (!Array.isArray(vehicles) || vehicles.length === 0) {
        return res.status(400).json({ status: 'error', message: 'Vehicles array is required' });
    }

    try {
        // 1️⃣ Get voucher_type_id using serial_code
        const voucherTypeQuery = `SELECT id FROM voucher_types WHERE serial_code = ?`;
        const voucherTypeResult = await dbQuery(voucherTypeQuery, [serial_code]);

        if (voucherTypeResult.length === 0) {
            return res.status(400).json({ status: 'error', message: 'Invalid serial_code' });
        }

        const voucher_type_id = voucherTypeResult[0].id;

        // 2️⃣ Get branch prefix and voucher_serial
        const branchSerialQuery = `SELECT prefix, voucher_serial FROM branch WHERE id = ?`;
        const branchSerialResult = await dbQuery(branchSerialQuery, [branch_id]);

        if (branchSerialResult.length === 0) {
            return res.status(400).json({ status: 'error', message: 'Invalid branch_id' });
        }

        const file_id = branchSerialResult[0].prefix + branchSerialResult[0].voucher_serial;

        // 3️⃣ Insert into voucherdetails
        let total_hour = 0;
        let net_amount_total = 0;
        let total_amount = 0;
        let total_shifting_charge = 0;
        let total_driver_salary = 0;
        let total_driver_bata = 0;

        for (const vehicle of vehicles) {
            for (const vd of vehicle.vehicles_data) {
                const net_amount = parseFloat(vd.amount || 0) +
                                   parseFloat(vd.shifting_charge || 0) +
                                   parseFloat(vd.driver_salary || 0) +
                                   parseFloat(vd.driver_bata || 0);

                const voucherdetailsQuery = `
                    INSERT INTO voucherdetails (
                        file_id, voucher_type_id, voucher_date, subledger_id, subledger_name, 
                        vehicle_id, vehicle_name, driver_id, driver_name, location_name, hour, 
                        rate, amount, need_shift, shifting_charge, driver_salary, driver_bata, 
                        payment_type_id, status, net_amount, branch_id, created_by
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                `;

                const voucherdetailsParams = [
                    file_id, voucher_type_id, voucher_date, vd.subledger_id, vd.subledger_name,
                    vd.vehicle_id, vd.vehicle_name, vd.driver_id, vd.driver_name, vd.location_name,
                    vd.hour, vd.rate, vd.amount, vd.need_shift, vd.shifting_charge,
                    vd.driver_salary, vd.driver_bata, vd.payment_type_id, vd.status, net_amount,
                    branch_id, created_by
                ];

                await dbQuery(voucherdetailsQuery, voucherdetailsParams);

                total_hour += parseFloat(vd.hour || 0);
                total_amount += parseFloat(vd.amount || 0);
                total_shifting_charge += parseFloat(vd.shifting_charge || 0);
                total_driver_salary += parseFloat(vd.driver_salary || 0);
                total_driver_bata += parseFloat(vd.driver_bata || 0);
                net_amount_total += net_amount;
            }
        }

        // 4️⃣ Insert into voucherhead
        const voucherheadQuery = `
            INSERT INTO voucherhead (
                file_id, voucher_type_id, voucher_date, total_hour, voucher_value, net_amount,
                total_amount, total_shifting_charge, total_driver_salary, total_driver_bata,
                branch_id, created_by
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;

        const voucherheadParams = [
            file_id, voucher_type_id, voucher_date, total_hour, net_amount_total, net_amount_total,
            total_amount, total_shifting_charge, total_driver_salary, total_driver_bata,
            branch_id, created_by
        ];

        await dbQuery(voucherheadQuery, voucherheadParams);

        // 5️⃣ Update branch voucher_serial
        const updateBranchSerialQuery = `UPDATE branch SET voucher_serial = voucher_serial + 1 WHERE id = ?`;
        await dbQuery(updateBranchSerialQuery, [branch_id]);

        // 6️⃣ Response
        res.status(200).json({
            status: 'success',
            message: 'Voucher created successfully',
            file_id
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({
            status: 'error',
            message: error.message || 'Database error occurred'
        });
    }
});
