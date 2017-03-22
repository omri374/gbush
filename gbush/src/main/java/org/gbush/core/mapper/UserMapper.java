package org.gbush.core.mapper;

import org.gbush.core.User;
import org.skife.jdbi.v2.StatementContext;
import org.skife.jdbi.v2.tweak.ResultSetMapper;

import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Created by omendels on 3/22/2017.
 */
public class UserMapper implements ResultSetMapper<User> {

    public User map(int index, ResultSet resultSet, StatementContext statementContext) throws SQLException
    {
        return new User(resultSet.getString("UserId"), resultSet.getString("pass"), resultSet.getInt("roleId"),resultSet.getInt("staffId"),resultSet.getString("initials"));
    }
}
