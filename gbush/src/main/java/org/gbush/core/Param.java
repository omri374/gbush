package org.gbush.core;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotNull;

/**
 * Created by omendels on 3/22/2017.
 */
public class Param {
    /*
    CREATE TABLE Param(
   ParamId INTEGER  NOT NULL PRIMARY KEY
  ,Name    VARCHAR(20) NOT NULL
  ,Value   NUMERIC(3,3) NOT NULL
);
     */

    @NotNull
    @JsonProperty
    private int paramId;

    @NotNull
    @JsonProperty
    private String name;

    @NotNull
    @JsonProperty
    private double value;

    public int getParamId() {
        return paramId;
    }

    public void setParamId(int paramId) {
        this.paramId = paramId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getValue() {
        return value;
    }

    public void setValue(double value) {
        this.value = value;
    }
}
