package org.gbush.resources;

import org.gbush.core.Role;
import org.gbush.db.RoleDao;

import javax.validation.Valid;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.util.List;

/**
 * Created by omendels on 3/22/2017.
 */
@Path("/role")
@Consumes({MediaType.APPLICATION_JSON})
@Produces({MediaType.APPLICATION_JSON})
public class RoleResource {

    RoleDao dao;

    public RoleResource(RoleDao dao) {
        this.dao = dao;
    }

    @GET
    public List<Role> getAll(){
        return dao.getAll();
    }

    @GET
    @Path("/{id}")
    public Role get(@PathParam("id") Integer id){
        return dao.findById(id);
    }

    @POST
    public Role add(@Valid Role Role) {
        dao.insert(Role);

        return Role;
    }

    @PUT
    @Path("/{id}")
    public Role update(@PathParam("id") Integer id, @Valid Role Role) {
        Role updateRole = new Role(id, Role.getName());

        dao.update(updateRole);

        return updateRole;
    }

    @DELETE
    @Path("/{id}")
    public void delete(@PathParam("id") Integer id) {
        dao.deleteById(id);
    }
}
