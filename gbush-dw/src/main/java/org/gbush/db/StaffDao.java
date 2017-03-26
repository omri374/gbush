package org.gbush.db;


import org.gbush.core.Staff;
import org.gbush.core.mapper.StaffMapper;
import org.skife.jdbi.v2.sqlobject.Bind;
import org.skife.jdbi.v2.sqlobject.BindBean;
import org.skife.jdbi.v2.sqlobject.SqlQuery;
import org.skife.jdbi.v2.sqlobject.SqlUpdate;
import org.skife.jdbi.v2.sqlobject.customizers.RegisterMapper;

import java.util.List;

/**
 * Created by omendels on 3/22/2017.
 */
@RegisterMapper(StaffMapper.class)
public interface StaffDao {
    @SqlUpdate("CREATE TABLE Staff(\n" +
            "   StaffId  INTEGER  NOT NULL PRIMARY KEY \n" +
            "  ,Initials VARCHAR(3) NOT NULL\n" +
            ");")
    void createSomethingTable();

    @SqlQuery("select * from Staff")
    List<Staff> getAll();

    @SqlQuery("select * from Staff where StaffId = :id")
    Staff findById(@Bind("id") int id);

    @SqlUpdate("delete from Staff where StaffId = :id")
    int deleteById(@Bind("id") int id);

    @SqlUpdate("update Staff " +
            "set Initials = :initials, " +
            "StaffId = :StaffId, " +
            "where StaffId = :id")
    int update(@BindBean Staff Staff);

    @SqlUpdate("insert into Staff(Initials,StaffId) values (:initials, :StaffId)")
    int insert(@BindBean Staff Staff);

}
