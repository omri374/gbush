package org.gbush.core;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.joda.time.LocalDate;

import javax.validation.constraints.NotNull;

/**
 * Created by omendels on 3/22/2017.
 */
public class Soldier {

    /*
    CREATE TABLE Soldier(
   SoldierId   VARCHAR(15) NOT NULL PRIMARY KEY
  ,City        INTEGER  NOT NULL
  ,Liba        BIT  NOT NULL
  ,ReleaseDate DATE  NOT NULL
  ,GiyusDate   DATE  NOT NULL
);
     */

    @NotNull
    @JsonProperty
    private int solderId;

    @NotNull
    @JsonProperty
    private int city; //city code

    @NotNull
    @JsonProperty
    private boolean isLiba;

    @NotNull
    @JsonProperty
    private LocalDate releaseDate;

    @NotNull
    @JsonProperty
    private LocalDate giyusDate;

    public Soldier(int solderId, int city, boolean isLiba, LocalDate releaseDate, LocalDate giyusDate) {
        this.solderId = solderId;
        this.city = city;
        this.isLiba = isLiba;
        this.releaseDate = releaseDate;
        this.giyusDate = giyusDate;
    }

    public int getSolderId() {

        return solderId;
    }

    public void setSolderId(int solderId) {
        this.solderId = solderId;
    }

    public int getCity() {
        return city;
    }

    public void setCity(int city) {
        this.city = city;
    }

    public boolean isLiba() {
        return isLiba;
    }

    public void setLiba(boolean liba) {
        isLiba = liba;
    }

    public LocalDate getReleaseDate() {
        return releaseDate;
    }

    public void setReleaseDate(LocalDate releaseDate) {
        this.releaseDate = releaseDate;
    }

    public LocalDate getGiyusDate() {
        return giyusDate;
    }

    public void setGiyusDate(LocalDate giyusDate) {
        this.giyusDate = giyusDate;
    }
}
