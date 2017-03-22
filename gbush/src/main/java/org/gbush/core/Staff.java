package org.gbush.core;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotNull;

/**
 * Created by omendels on 3/22/2017.
 * CREATE TABLE Staff(
 StaffId  INTEGER  NOT NULL PRIMARY KEY
 ,Initials VARCHAR(3) NOT NULL
 );
 */


public class Staff {

    @NotNull
    @JsonProperty
    private int staffId;
    @NotNull
    @JsonProperty
    private String initials;

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

    public Staff(int staffId, String initials) {

        this.staffId = staffId;
        this.initials = initials;
    }
}
