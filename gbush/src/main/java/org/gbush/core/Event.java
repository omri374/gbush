package org.gbush.core;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotNull;

/**
 * Created by omendels on 3/22/2017.
 *
 * CREATE TABLE Event(
 EventId  INTEGER  NOT NULL PRIMARY KEY
 ,Name     VARCHAR(30) NOT NULL
 ,Type     VARCHAR(20) NOT NULL
 ,IsActive BIT  NOT NULL
 );
 */
public class Event {

    @NotNull
    @JsonProperty
    private int eventId;

    @NotNull
    @JsonProperty
    private String name;

    @NotNull
    @JsonProperty
    private EventType type;

    @NotNull
    @JsonProperty
    private boolean isActive;

    public Event(int eventId, String name, EventType type, boolean isActive) {
        this.eventId = eventId;
        this.name = name;
        this.type = type;
        this.isActive = isActive;
    }

    public int getEventId() {

        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public EventType getType() {
        return type;
    }

    public void setType(EventType type) {
        this.type = type;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }
}
