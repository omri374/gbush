package org.gbush.db;


import org.gbush.core.User;
import org.gbush.core.mapper.UserMapper;
import org.skife.jdbi.v2.sqlobject.Bind;
import org.skife.jdbi.v2.sqlobject.BindBean;
import org.skife.jdbi.v2.sqlobject.SqlQuery;
import org.skife.jdbi.v2.sqlobject.SqlUpdate;
import org.skife.jdbi.v2.sqlobject.customizers.RegisterMapper;

import java.util.List;

/**
 * Created by omendels on 3/22/2017.
 */
@RegisterMapper(UserMapper.class)
public interface UserDao {
    @SqlUpdate("CREATE TABLE User(\n" +
            "   Initials VARCHAR(2) NOT NULL\n" +
            "  ,UserId   VARCHAR(15) NOT NULL PRIMARY KEY\n" +
            "  ,Pass     VARCHAR(15) NOT NULL\n" +
            "  ,RoleId   INTEGER  NOT NULL\n" +
            "  ,StaffId  INTEGER  NOT NULL\n" +
            "  ,Foreign Key (RoleId) REFERENCES Role(RoleId)\n" +
            "    ,Foreign Key (StaffId,Initials) REFERENCES Staff(StaffId,Initials)\n" +
            ");")
    void createSomethingTable();

    @SqlQuery("select * from User")
    List<User> getAll();

    @SqlQuery("select * from User where UserId = :id")
    User findById(@Bind("id") int id);

    @SqlUpdate("delete from User where UserId = :id")
    int deleteById(@Bind("id") int id);

    @SqlUpdate("update User " +
            "set Initials = :initials, " +
            "UserId = :userId, " +
            "Pass = :pass, " +
            "RoleId = :roleId, " +
            "StaffId = :staffId, " +
            "where UserId = :id")
    int update(@BindBean User user);

    @SqlUpdate("insert into User(Initials,UserId,Pass,RoleId,StaffId) values (:initials, :userId, :pass, :roleId, :staffId)")
    int insert(@BindBean User user);

}
