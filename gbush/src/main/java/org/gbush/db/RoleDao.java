package org.gbush.db;


import org.gbush.core.Role;
import org.gbush.core.mapper.RoleMapper;
import org.skife.jdbi.v2.sqlobject.Bind;
import org.skife.jdbi.v2.sqlobject.BindBean;
import org.skife.jdbi.v2.sqlobject.SqlQuery;
import org.skife.jdbi.v2.sqlobject.SqlUpdate;
import org.skife.jdbi.v2.sqlobject.customizers.RegisterMapper;

import java.util.List;

/**
 * Created by omendels on 3/22/2017.
 */
@RegisterMapper(RoleMapper.class)
public interface RoleDao {
    @SqlUpdate("CREATE TABLE Role(\n" +
            "   RoleId INTEGER  NOT NULL PRIMARY KEY \n" +
            "  ,Name VARCHAR(8) NOT NULL\n" +
            ");")
    void createSomethingTable();

    @SqlQuery("select * from Role")
    List<Role> getAll();

    @SqlQuery("select * from ROLE where RoleId = :id")
    Role findById(@Bind("id") int id);

    @SqlUpdate("delete from ROLE where RoleId = :id")
    int deleteById(@Bind("id") int id);

    @SqlUpdate("update ROLE set NAME = :name where RoleId = :id")
    int update(@BindBean Role role);

    @SqlUpdate("insert into ROLE (RoleId, NAME) values (:id, :name)")
    int insert(@BindBean Role role);

}
