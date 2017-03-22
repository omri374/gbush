package org.gbush.core;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.security.auth.Subject;
import javax.validation.constraints.NotNull;
import java.security.Principal;
import java.util.List;
import java.util.Set;


/*
CREATE TABLE User(
   Initials VARCHAR(2) NOT NULL
  ,UserId   VARCHAR(15) NOT NULL PRIMARY KEY
  ,Pass     VARCHAR(15) NOT NULL
  ,RoleId   INTEGER  NOT NULL
  ,StaffId  INTEGER  NOT NULL
  ,Foreign Key (RoleId) REFERENCES Role(RoleId)
    ,Foreign Key (StaffId,Initials) REFERENCES Staff(StaffId,Initials)
);
 */

public class User implements Principal {

    @NotNull
    @JsonProperty
    private String userId;

    @NotNull
    @JsonProperty
    private String pass;

    @NotNull
    @JsonProperty
    private int roleId;

    @NotNull
    @JsonProperty
    private int staffId;

    @NotNull
    @JsonProperty
    private String initials;

    public User(String userId, String pass, int roleId, int staffId, String initials) {
        this.userId = userId;
        this.pass = pass;
        this.roleId = roleId;
        this.staffId = staffId;
        this.initials = initials;
    }

    public User(String username, Set<String> strings) {

    }


    public String getUserId() {

        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getPass() {
        return pass;
    }

    public void setPass(String pass) {
        this.pass = pass;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public int getStaffId() {
        return staffId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public String getInitials() {
        return initials;
    }

    public void setInitials(String initials) {
        this.initials = initials;
    }

    @Override
    public String getName() {
        return userId;
    }

    @Override
    public boolean implies(Subject subject) {
        return false;
    }

    public List<String> getRoles() {
        return null;
    }
}
