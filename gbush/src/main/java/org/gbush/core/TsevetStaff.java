package org.gbush.core;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotNull;

/**
 * Created by omendels on 3/22/2017.
 */
public class TsevetStaff {

    /*
CREATE TABLE TsevetStaff(
   StaffId      INTEGER NOT NULL
  ,EventId      INTEGER  NOT NULL
  ,TsevetId     INTEGER  NOT NULL
  ,TsevetRoleId INTEGER  NOT NULL
   ,PRIMARY KEY(StaffId, EventId, TsevetId, TsevetRoleId)
   ,Foreign Key (StaffId) REFERENCES Staff(StaffId)
   ,Foreign Key (EventId) REFERENCES Event(EventId)
   ,Foreign Key (TsevetId) REFERENCES Tsevet(TsevetId)
);
     */

    @NotNull
    @JsonProperty
    private int staffId;


    @NotNull
    @JsonProperty
    private int eventId;


    @NotNull
    @JsonProperty
    private int tsevetId;


    @NotNull
    @JsonProperty
    private int tsevetRoleId;

}
