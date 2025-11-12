router.get('/listdrivers', async (req, res) => {
    let { search, subledger_type } = req.query;

    try {
        let query = `
            SELECT s.id, s.name, s.phone, s.subledger_type, st.name AS subledger_type_name,
            s.address, s.branch_id, s.created_by, sc.name AS created_by_name
            FROM subledgers s
            LEFT JOIN subledger_type st ON s.subledger_type = st.id
            LEFT JOIN subledgers sc ON s.created_by = sc.id
            WHERE s.is_active = 'Y'
        `;
        let params = [];

        // Search condition
        if (search && search.trim() !== '') {
            query += ` AND (s.name LIKE ? OR s.phone LIKE ?)`;
            params.push(`%${search}%`, `%${search}%`);
        }

        // Subledger type condition
        if (subledger_type && subledger_type.trim() !== '') {
            query += ` AND s.subledger_type = ?`;
            params.push(subledger_type);
        }

        query += ` ORDER BY s.name ASC`;

        const result = await dbQuery(query, params);

        res.status(200).json({
            status: 'success',
            data: result
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({
            status: 'error',
            message: 'Some error occurred. Please try again later.'
        });
    }
});