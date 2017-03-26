package org.gbush.auth;


import io.dropwizard.auth.Authorizer;
import org.gbush.core.User;

public class GbushAuthorizer implements Authorizer<User> {

    @Override
    public boolean authorize(User user, String role) {
        return user.getRoles() != null && user.getRoles().contains(role);
    }
}
