package org.gbush.core;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotNull;

/**
 * Created by omendels on 3/22/2017.
 */
public class ScoreParam {
    /*
    CREATE TABLE ScoreParam(
   ScoreParamId INTEGER  NOT NULL PRIMARY KEY
  ,Name         VARCHAR(32) NOT NULL
    );
     */

    @NotNull
    @JsonProperty
    private int scoreParamId;

    @NotNull
    @JsonProperty
    private String paramName;

    public ScoreParam(int scoreParamId, String paramName) {
        this.scoreParamId = scoreParamId;
        this.paramName = paramName;
    }

    public int getScoreParamId() {

        return scoreParamId;
    }

    public void setScoreParamId(int scoreParamId) {
        this.scoreParamId = scoreParamId;
    }

    public String getParamName() {
        return paramName;
    }

    public void setParamName(String paramName) {
        this.paramName = paramName;
    }
}
