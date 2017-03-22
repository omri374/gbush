package org.gbush.core;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotNull;

/**
 * Created by omendels on 3/22/2017.
 */
public class Tsevet {

    /*
    CREATE TABLE Tsevet(
   TsevetId      INTEGER  NOT NULL PRIMARY KEY
  ,Matam		INTEGER NOT NULL
  ,Number		INTEGER	NOT NULL
    );
     */

    @NotNull
    @JsonProperty
    private int tsevetId;

    @NotNull
    @JsonProperty
    private int matam;

    @NotNull
    @JsonProperty
    private int number;

    public Tsevet(int tsevetId, int matam, int number) {
        this.tsevetId = tsevetId;
        this.matam = matam;
        this.number = number;
    }

    public int getTsevetId() {

        return tsevetId;
    }

    public void setTsevetId(int tsevetId) {
        this.tsevetId = tsevetId;
    }

    public int getMatam() {
        return matam;
    }

    public void setMatam(int matam) {
        this.matam = matam;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }
}
