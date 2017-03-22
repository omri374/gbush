package org.gbush.core.mapper;

import org.gbush.core.Staff;
import org.skife.jdbi.v2.StatementContext;
import org.skife.jdbi.v2.tweak.ResultSetMapper;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Created by omendels on 3/22/2017.
 */
public class StaffMapper implements ResultSetMapper<Staff> {

    public Staff map(int index, ResultSet resultSet, StatementContext statementContext) throws SQLException
    {
        return new Staff(resultSet.getInt("StaffId"),resultSet.getString("initials"));
    }
}
