router.post('/listvouchersbypagination', async (req, res) => {
    const {
        start_date,
        end_date,
        term,
        voucher_type_id,
        branch_id,
        page = 1,
        limit = 20
    } = req.body;

    try {
        const offset = (page - 1) * limit;
        const branchIdsArray = branch_id ? branch_id.split(',').map(id => id.trim()) : [];

        let baseQuery = `
            FROM voucherhead vh
            JOIN branch b ON b.id = vh.branch_id
            JOIN subledgers s ON s.id = vh.subledger_id
            LEFT JOIN subledgers creator ON creator.id = vh.created_by
            WHERE vh.is_active = 'Y'
        `;

        let queryParams = [];

        // Optional date filter
        if (start_date && end_date) {
            baseQuery += ` AND DATE(vh.voucher_date) BETWEEN ? AND ?`;
            queryParams.push(start_date, end_date);
        }

        // Optional filters
        if (term) {
            baseQuery += ` AND (vh.subledger_name LIKE ? OR vh.file_id LIKE ?)`;
            queryParams.push(`%${term}%`, `%${term}%`);
        }

        if (voucher_type_id) {
            baseQuery += ` AND vh.voucher_type_id = ?`;
            queryParams.push(voucher_type_id);
        }

        if (branchIdsArray.length > 0) {
            baseQuery += ` AND vh.branch_id IN (${branchIdsArray.map(() => '?').join(',')})`;
            queryParams.push(...branchIdsArray);
        }

        // Count query
        const countQuery = `SELECT COUNT(*) AS count ${baseQuery}`;
        const countResult = await dbQuery(countQuery, queryParams);
        const totalCount = countResult[0].count;
        const totalPages = Math.ceil(totalCount / limit);

        // Main query
        const dataQuery = `
            SELECT 
                vh.*, 
                b.name AS branch_name,
                s.phone AS phonenumber,
                
            ${baseQuery}
            GROUP BY vh.file_id
            ORDER BY vh.file_id DESC
            LIMIT ? OFFSET ?
        `;

        const dataParams = [...queryParams, parseInt(limit), parseInt(offset)];
        const vouchers = await dbQuery(dataQuery, dataParams);

        return res.status(200).json({
            status: 'success',
            data: vouchers,
            totalPages,
            totalCount
        });

    } catch (error) {
        console.error(error);
        return res.status(500).json({
            status: 'error',
            message: error.message || 'Database error occurred'
        });
    }
});
