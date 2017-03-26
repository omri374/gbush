package org.gbush.core;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotNull;

/**
 * Created by omendels on 3/22/2017.
 */
public class SoldierScore {
    /*
    CREATE TABLE SoldierScore(
   SoldierId    VARCHAR(15) NOT NULL
  ,EventId      INTEGER  NOT NULL
  ,ScoreParamId     INTEGER  NOT NULL
  ,Value          NUMERIC(3,3)  NOT NULL
  ,Description          VARCHAR(255)
  ,PRIMARY KEY(SoldierId,EventId,ScoreParamId)
  ,Foreign Key (SoldierId) REFERENCES Soldier(SoldierId)
  ,Foreign Key (EventId) REFERENCES Event(EventId)
  ,Foreign Key (ScoreParamId) REFERENCES ScoreParam(ScoreParamId)

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
    private int scoreParamId;

    @NotNull
    @JsonProperty
    private double value;

    @NotNull
    @JsonProperty
    private String description;

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

    public int getScoreParamId() {
        return scoreParamId;
    }

    public void setScoreParamId(int scoreParamId) {
        this.scoreParamId = scoreParamId;
    }

    public double getValue() {
        return value;
    }

    public void setValue(double value) {
        this.value = value;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
