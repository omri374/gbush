package org.gbush.core;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotNull;

/**
 * Created by omendels on 3/22/2017.
 */
public class SoldierInTsevet {

    /*
    CREATE TABLE SoldierInTsevet(
   SoldierId VARCHAR(15) NOT NULL
  ,EventId   INTEGER  NOT NULL
  ,TsevetId  INTEGER  NOT NULL
  ,Hat       INTEGER  NOT NULL
  ,PRIMARY KEY(SoldierId,EventId,TsevetId)
  ,Foreign Key (TsevetId) REFERENCES Tsevet(TsevetId)
  ,Foreign Key (EventId) REFERENCES Event(EventId)
);
     */

    @NotNull
    @JsonProperty
    private String soldierId;

    @NotNull
    @JsonProperty
    private int eventId;

    @NotNull
    @JsonProperty
    private int tsevetId;

    @NotNull
    @JsonProperty
    private int hatNumber;

    public SoldierInTsevet(String soldierId, int eventId, int tsevetId, int hatNumber) {
        this.soldierId = soldierId;
        this.eventId = eventId;
        this.tsevetId = tsevetId;
        this.hatNumber = hatNumber;
    }

    public String getSoldierId() {

        return soldierId;
    }

    public void setSoldierId(String soldierId) {
        this.soldierId = soldierId;
    }

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public int getTsevetId() {
        return tsevetId;
    }

    public void setTsevetId(int tsevetId) {
        this.tsevetId = tsevetId;
    }

    public int getHatNumber() {
        return hatNumber;
    }

    public void setHatNumber(int hatNumber) {
        this.hatNumber = hatNumber;
    }
}
