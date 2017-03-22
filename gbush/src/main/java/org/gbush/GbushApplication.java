package org.gbush;

import io.dropwizard.Application;
import io.dropwizard.jdbi.DBIFactory;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import org.gbush.db.RoleDao;
import org.gbush.resources.RoleResource;
import org.skife.jdbi.v2.DBI;

public class GbushApplication extends Application<GbushConfiguration> {

    public static void main(String[] args) throws Exception {
        new GbushApplication().run(args);
    }

    @Override
    public String getName() {
        return "hello-world";
    }

    @Override
    public void initialize(Bootstrap<GbushConfiguration> bootstrap) {
        // nothing to do yet
    }

    @Override
    public void run(GbushConfiguration configuration,
                    Environment environment) {

        final DBIFactory factory = new DBIFactory();
        final DBI jdbi = factory.build(environment, configuration.getDataSourceFactory(), "h2");
        final RoleDao dao = jdbi.onDemand(RoleDao.class);
        environment.jersey().register(new RoleResource(dao));
    }

}
