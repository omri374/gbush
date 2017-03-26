package org.gbush.core.mapper;

import org.gbush.core.Role;
import org.skife.jdbi.v2.StatementContext;
import org.skife.jdbi.v2.tweak.ResultSetMapper;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Created by omendels on 3/22/2017.
 */
public class RoleMapper  implements ResultSetMapper<Role> {

    public Role map(int index, ResultSet resultSet, StatementContext statementContext) throws SQLException
    {
        return new Role(resultSet.getInt("RoleId"), resultSet.getString("Name"));
    }
}
